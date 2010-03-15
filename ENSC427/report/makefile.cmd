@echo off

set path=%path%;"C:\Program Files\MiKTeX 2.8\miktex\bin"

set FILENAME=finalReport

set BIBNAME=finalReport



pdflatex --interaction nonstopmode %FILENAME%

bibtex %FILENAME%

pdflatex --interaction nonstopmode %FILENAME% 

pdflatex --interaction nonstopmode %FILENAME%

echo.
echo Done compile, going to clean
pause

echo.
call clean.cmd
echo Done clean, going to exit
pause