@echo off

set FILENAME=finalReport

set BIBNAME=finalReport



pdflatex --interaction nonstopmode %FILENAME%

bibtex %FILENAME%

pdflatex --interaction nonstopmode %FILENAME% 

pdflatex --interaction nonstopmode %FILENAME%

echo Done compile, going to clean
pause

call clean.cmd
echo Done clean, going to exit
pause