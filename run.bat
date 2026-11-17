@echo off
chcp 65001 >nul
title He thong quan li nha hang - De 21
cd /d "%~dp0"
echo Dang bien dich va khoi dong (lan dau Maven se tai thu vien, mat 1-2 phut)...
call mvn -q compile exec:java
pause
