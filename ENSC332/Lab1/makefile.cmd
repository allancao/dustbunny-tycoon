@echo off
setlocal

set FILENAME=report
set BIBNAME=References

:: Just in canse paths not set up right
if exist "C:\Program Files\MiKTeX 2.8\miktex\bin" set path=%path%;"C:\Program Files\MiKTeX 2.8\miktex\bin"&&echo Updated PATH

::###########################################
:: Delete current PDF
::###########################################

if exist %FILENAME%.pdf (
  echo Going to delete current PDF
  pause

  del %FILENAME%.pdf

  if exist %FILENAME%.pdf (
    echo.
    echo Could not delete pdf, please close it if it is open
    goto :END
  )
)

::###########################################
:: Clean 
::###########################################

echo.
echo Going to clean

echo.
call clean.cmd

::###########################################
:: Compile
::###########################################

::pdflatex --interaction nonstopmode %FILENAME%
pdflatex %FILENAME%


::pause

bibtex %FILENAME%

pdflatex --interaction nonstopmode %FILENAME% 

pdflatex %FILENAME%

if not exist %FILENAME%.pdf (
  echo Not generate PDF, please look up to see if there were any errors
  goto :END
)

::###########################################
:: Clean
::###########################################

::DISABLED

::echo.
::echo Done compile, going to clean

::echo.
::call clean.cmd


::###########################################
:: Show it
::###########################################

echo Opening PDF
::start %FILENAME%.pdf

copy %FILENAME%.pdf %UNISON_SYNC_DIR%\%FILENAME%.pdf  /Y

%EC2_DIR%\unison.exe %UNISON_SYNC_DIR% %UNISON_REMOTE_SYNC_DIR% -sshcmd "%EC2_DIR%\unisonssh.cmd" -batch

::###########################################
:: END
::###########################################
:END

echo.
echo Done, going to exit
pause