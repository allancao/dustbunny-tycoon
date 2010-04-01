import os
import sys
import ftplib
import re

print "Starting"
print ""
print "Processing csvs into 427.txt"

#Get file list
filesToSend = ["427.txt"]
for srcFile in os.listdir(os.getcwd()):
    if os.path.isfile(srcFile):
        if srcFile.endswith(".PNG"):
            filesToSend.append(srcFile)

#Process .csv
srcCsvs = [ "427-2.csv",
            "427-3.csv",
            "427-4.csv",
            "427-5.csv",
            "427-6.csv"]

src = None
dest = None
if os.path.exists("427.txt"):
    os.remove("427.txt")

res = [ (re.compile("^,\\n", re.MULTILINE), "", "Empty lines"),
        (re.compile("^\s*#.*\\n", re.MULTILINE),"", "Comment lines"),
        (re.compile("[,](?=(([^\"]*)|([^\"]*([\"][^\"]*){2}))$)", re.MULTILINE), "\t", "Comma -> Tab"),
        (re.compile("(?<=[\\t])[\"](?P<content>[^\"]*)[\"](?=[\\t]|($))", re.MULTILINE), "\\g<content>", "Quotation removal for commas"),
        (re.compile("img\\:(?P<test>[\\w-]+)"),"<img src=\"http://www.sfu.ca/~danh/Study/\\g<test>.PNG\"/>", "IMG Tag placement")]

try:
    dest = open("427.txt", "w")
    for srcCsv in srcCsvs:
        print "   Processing " + srcCsv
        src = open(srcCsv, "r")
        txt = src.read()
        
        txt = txt.replace("\t", "   ") #Cant have tabs
        for reToApply in res:
            #print "         Process: " + reToApply[2]
            txt = re.sub(reToApply[0], reToApply[1], txt)
        
        dest.write(txt+"\n")
        src.close()
finally:
    if not src is None:
        src.close()
    if not dest is None:
        dest.close()

print "      CSVs processed, going to upload"

#raw_input("DEBUG Done. Press Enter...")
#exit()

print ""
ftp = None
try:

    ftp = ftplib.FTP("ftp.sfu.ca", "danh", raw_input("FTP PWD: "))
    
    result = ftp.cwd("pub_html")
    assert result.startswith("250")
    result = ftp.cwd("Study")
    assert result.startswith("250")
    
    print "Logon and directory switch success, going to store"
    
    currentFiles = ftp.nlst()
    currentFiles.remove("427.txt")
    
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