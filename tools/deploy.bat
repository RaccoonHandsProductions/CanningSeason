rem Install to all connected devices
@echo off
cls
FOR /F "tokens=1,2" %%a IN ('adb.exe devices') DO (
    IF "%%b" == "device" ( start /b adb.exe -s %%a install -r ../build/android/CanningSeason.apk )
)