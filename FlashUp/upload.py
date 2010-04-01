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
assert len(currentDirListing) #Should never be the case as at least this file should be in the directory

image_extractor_regex = re.compile("img\\:(?P<img>[\\w-]+)")
imagesUsed = [] #List of images used in the csvs

###################################################
#### CSV processing
###################################################

print ""
print "Processing CSVs into " + DECK_FILE

if os.path.exists(DECK_FILE):
    os.remove(DECK_FILE)

#Regexes used to process the csvs
csv_regex = [ (re.compile("^,\\n", re.MULTILINE), "", "Empty lines"),
        (re.compile("^\s*#.*\\n", re.MULTILINE),"", "Comment lines"),
        (re.compile("[,](?=(([^\"]*)|([^\"]*([\"][^\"]*){2}))$)", re.MULTILINE), "\t", "Comma -> Tab"),
        (re.compile("(?<=[\\t])[\"](?P<content>[^\"]*)[\"](?=[\\t]|($))", re.MULTILINE), "\\g<content>", "Quotation removal for commas"),
        (image_extractor_regex,"<img src=\"" + WEB_ROOT + WEB_DECK_DIR + "/\\g<img>.PNG\"/>", "IMG Tag placement")]

#Get a list of .csv files in the current directory
srcCsvs = []
for srcFile in currentDirListing:
        if srcFile.lower().endswith(".csv"):
            srcCsvs.append(srcFile)
#Make sure there are sources
assert len(srcCsvs) > 0, "No source CSVs in the current directory"

src = None
dest = None
try:
    dest = open(DECK_FILE, "w")
    for srcCsv in srcCsvs:
        print "   Processing " + srcCsv
        #Open and read the src csv
        src = open(srcCsv, "r")
        txt = src.read()
        src.close()
        
        #Get the list of images the source uses
        for match in re.finditer(image_extractor_regex, txt):
            img = match.group("img")
            assert len(img) > 0
            if not img in imagesUsed:
                imagesUsed.append(img)
        
        #Process using the regular expressions listed above 
        txt = txt.replace("\t", "   ") #Cant have tabs
        for reToApply in csv_regex:
            #print "         Process: " + reToApply[2]
            txt = re.sub(reToApply[0], reToApply[1], txt)
        
        #Write to the destination
        dest.write(txt+"\n")
finally:
    if not src is None:
        src.close()
    if not dest is None:
        dest.close()

print "      CSVs processed"

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
    print "  WARNING: Used but does not exist \'%s.PNG\'" % dneImg

###################################################
#### FTP Upload
###################################################

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

print ""
raw_input("Done. Press Enter...")