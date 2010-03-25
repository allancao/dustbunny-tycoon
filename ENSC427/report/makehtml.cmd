@echo off
setlocal

set FILENAME=finalReport

set BIBNAME=finalReport


:: For timbo - paths not set up right
if exist "C:\Program Files\MiKTeX 2.8\miktex\bin" set path=%path%;"C:\Program Files\MiKTeX 2.8\miktex\bin"&&echo Updated PATH

::###########################################
:: Delete current HTML
::###########################################

if exist %FILENAME%.html (
  echo Going to delete current HTML
  pause

  del %FILENAME%.html

  if exist %FILENAME%.html (
    echo.
    echo Could not delete
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

latex %FILENAME%


::pause

bibtex %FILENAME%
latex %FILENAME%


htlatex %FILENAME%


if not exist %FILENAME%.html (
  echo Not generate, please look up to see if there were any errors
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

echo Opening 
%FILENAME%.html

::###########################################
:: END
::###########################################
:END

echo.
echo Done, going to exit
pause