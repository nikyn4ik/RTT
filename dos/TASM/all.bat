@echo off
cls

rem --------------------------------
echo ------ Assembling... -------------------------------------------------
rem echo.
rem /zi, которая включает полную информацию для отладчика
rem /iпуть
TASM.EXE /zi /ilib %1.asm
rem rem IF errorlevel 1 goto err_end
rem echo ------ Assembling completed succesfully ------------------------------
rem echo.
rem echo.
rem rem pause
rem 
rem rem --------------------------------
rem 
echo ------ Linking... ----------------------------------------------------
rem echo.
rem TLINK.EXE -M -V %1.obj
rem /v, которая говорит о том, что в проект нужно включить полную информацию
TLINK.EXE /v %1.obj
rem IF errorlevel 1 goto err_end
rem echo.
rem echo ------ Linking completed succesfully ---------------------------------
rem echo.
rem echo.
rem pause

rem --------------------------------
echo ------ running... ----------------------------------------------------
%1
rem echo.
rem echo === Build completed succesfully ======================================
rem TD.EXE %1.exe
rem goto end
rem 
rem :err_end
rem echo.
rem echo ====== There are errors ! Building has been cancelled ================
rem pause
rem :end
rem @echo on
