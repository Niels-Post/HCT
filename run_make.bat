@echo off & SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
mode con: cols=280
set "working_dir=%cd:\=/%"
set "driveletter=%working_dir:~0,1%"
call :tolower driveletter

set "working_dir=/mnt/%driveletter%%working_dir:~2%"
shift
set "makefile=%1"
set "makefile=%makefile:\=/%"
set "makefile=/mnt/%driveletter%%makefile:~2%"
shift

IF "%~1" == "" (set "maketarget=run") else (set "maketarget=%1")

shift

IF "%maketarget%"=="clean" (
C:\Windows\Sysnative\wsl export DISPLAY=localhost:0.0; cd %working_dir%; make -f %makefile% %maketarget%; exit; > NUL
) ELSE (
C:\Windows\Sysnative\wsl export DISPLAY=localhost:0.0; cd %working_dir%; make -f %makefile% %maketarget%; exit;
)


if "%maketarget%"=="run" (
exit -1 /b
) else (
exit /b
)
:tolower
for %%L IN (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO SET %1=!%1:%%L=%%L!
goto :EOF

:eof