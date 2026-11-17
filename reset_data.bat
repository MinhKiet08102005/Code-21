@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Xoa CSDL H2 va anh tai len de quay ve du lieu mau ban dau.
echo Hay tat ung dung (cua so run.bat) truoc khi tiep tuc.
pause
if exist data rmdir /s /q data
del /q src\main\webapp\uploads\dish_* 2>nul
echo Da xoa. Lan chay run.bat tiep theo se tao lai du lieu mau.
pause
