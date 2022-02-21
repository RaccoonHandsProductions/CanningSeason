rem Build the APK
C:\Users\Public\Desktop\Godot_v3.4.2-stable_win64.exe -v --export-debug Android ..\build\android\CanningSeason.apk ..\project\project.godot

rem Install to all connected devices
@echo off
cls
FOR /F "tokens=1,2" %%a IN ('adb.exe devices') DO (
    IF "%%b" == "device" ( start /b adb.exe -s %%a install -r ../build/android/CanningSeason.apk )
)