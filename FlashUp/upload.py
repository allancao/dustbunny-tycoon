import win32com.client

import os
import sys
import ftplib
import re

print "Starting"

###################################################
#### Primary Variables
###################################################

#Deck name & output file
DECK_NAME = os.path.basename(os.path.abspath(os.curdir))
DECK_FILE = DECK_NAME + ".txt"

# FTP and web
FTP_SERVER = "ftp.sfu.ca"
FTP_USERNAME = "danh"
FTP_PUB_HTML = "pub_html" #Where can we put files so they are accessible from WEB_ROOT
WEB_ROOT = "http://www.sfu.ca/~danh/"
WEB_DECK_DIR = DECK_NAME

#Variables
filesToSend = [DECK_FILE]

currentDirListing = []
for randomFile in os.listdir(os.curdir):
    if os.path.isfile(randomFile):
        currentDirListing.append(randomFile)
assert len(currentDirListing) > 0 #Should never be the case as at least this file should be in the directory

image_extractor_regex = re.compile("img\\:(?P<img>[\\w-]+)")
image_replacement_regex = "<img src=\"" + WEB_ROOT + WEB_DECK_DIR + "/\\g<img>.PNG\"/>"
imagesUsed = [] #List of images used in the csvs

###################################################
#### Excel processing
###################################################

print ""
print "Processing Excel files"

#Get a list of .xlsx files in the current directory
srcXls = []
for srcFile in currentDirListing:
        #TODO: Handle standard .xls
        if srcFile.startswith("~"):
            #Excel backups
            continue
        if srcFile.lower().endswith(".xlsx"):
            srcXls.append(srcFile)
#Make sure there are sources
assert len(srcXls) > 0, "No source XLSXs in the current directory"

excel = None
cards = [] #List of tuples
try:
    excel = win32com.client.DispatchEx("Excel.Application")
    for srcXl in srcXls:
        print "   Processing " + srcXl
        wb = None
        ws = None
        try:
            wb = excel.Workbooks.Open(os.path.abspath(srcXl), ReadOnly=True)
            ws = wb.Worksheets[0]
            i = 1
            while i < 1000:
                newCardSide1 = ws.Range("A" + str(i)).Value
                newCardSide2 = ws.Range("B" + str(i)).Value
                
                if (newCardSide1 is None and newCardSide2 is None):
                    print "     Examined %s rows from %s" % (i-1, srcXl)
                    break
                
                try:
                    newCardSide1 = str(newCardSide1)
                    newCardSide2 = str(newCardSide2)
                except UnicodeEncodeError:
                    print "      Encoding error on row " + str(i)
                    i += 1
                    continue
                
                if not newCardSide1.startswith("#"):
                    cards.append((newCardSide1, newCardSide2))
                
                i += 1
        finally:
            ws = None
            if not wb is None:
                wb.Close()
                wb = None
finally:
    if not excel is None:
        excel.Quit()
        excel = None

print "Excel files processed"
assert len(cards) > 0, "No cards"

###################################################
#### Output Processing 
###################################################

print ""
print "Creating output " + DECK_FILE

if os.path.exists(DECK_FILE):
    os.remove(DECK_FILE)

dest = None
cardCount = 0
try:
    dest = open(DECK_FILE, "w")
    for card in cards:
        cardCount += 1 
        for cardSide in card:
            if cardSide is None:
                cardSide = ""
            
            #Get images
            for match in re.finditer(image_extractor_regex, cardSide):
                img = match.group("img")
                assert len(img) > 0
                if not img in imagesUsed:
                    imagesUsed.append(img)
            
            #Text processing
            cardSide = cardSide.replace("\t", "  ")
            cardSide = re.sub(image_extractor_regex, image_replacement_regex, cardSide)
            
            #Write to output
            dest.write(cardSide)
            dest.write("\t")
        
        dest.write("\n")
finally:
    dest.close()

print "Done creating output, %s cards total" % cardCount

###################################################
#### Image Checking
###################################################

print ""
print "Checking Images"

for pngFile in currentDirListing:
    #This is not terribly efficient but who cares at the moment
    if pngFile.endswith(".PNG"): #Note case sensitive TODO: fix
        pngName = pngFile.rpartition(".")[0]
        
        if pngName in imagesUsed:
            filesToSend.append(pngFile)
            imagesUsed.remove(pngName)
        else:
            print "  NOTE: Unused Img \'%s\'" % pngFile

for dneImg in imagesUsed:
    print "  WARNING: Image used but does not exist \'%s.PNG\'" % dneImg

imagesUsed = None #No longer valid - imgs have been removed

print "Done checking images"

###################################################
#### FTP Upload
###################################################

#print "DEBUG - breaking before FTP"
#exit()

print ""
print "Connecting to FTP " + FTP_SERVER

ftp = None
try:

    ftp = ftplib.FTP(FTP_SERVER, FTP_USERNAME, raw_input("  Password for %s: " % FTP_USERNAME))
    
    result = ftp.cwd(FTP_PUB_HTML)
    assert result.startswith("250"), result
    
    #TODO: Create directory if it does not exist
    result = ftp.cwd(WEB_DECK_DIR)
    assert result.startswith("250"), result
    
    print "Logon and directory switch success, going to store"
    
    #Get the list of current files
    currentFiles = []
    try:
        currentFiles = ftp.nlst()
    except ftplib.error_perm as err:
        #eat this exception
        if str(err).startswith("550"):
            print "Empty Directory"
        else:
            print str(err).startswith("550")
            print "Exception: \"%s\"" % err.args
            raise
    
    if DECK_FILE in currentFiles:
        ftp.delete(DECK_FILE)
        currentFiles.remove(DECK_FILE)
    
    for srcFile in filesToSend:
        if srcFile in currentFiles:
            print "   Skipping " + srcFile
            currentFiles.remove(srcFile)
            continue
        
        f = None
        try:
            f = open(srcFile, "rb")
            result = ftp.storbinary("STOR " + srcFile, f)
            assert result.startswith("226")
            print "   Stored " + srcFile
        finally:
            if not f is None:
                f.close()
    
    for unused in currentFiles:
        result = ftp.delete(unused)
        assert result.startswith("250")
        print "   Deleted " + unused
    
finally:
    if not ftp is None:
        ftp.close()
print "FTP upload done"

print ""
raw_input("Done. Press Enter...")