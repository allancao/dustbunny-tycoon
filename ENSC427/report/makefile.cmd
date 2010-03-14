@echo off

set FILENAME=finalReport

set BIBNAME=finalReport



pdflatex --interaction nonstopmode %FILENAME%

bibtex %FILENAME%

pdflatex --interaction nonstopmode %FILENAME% 

pdflatex --interaction nonstopmode %FILENAME%



del *.dvi *.ps *.aux *.log *.bbl *.blg *.out *.lot *.lof *.toc