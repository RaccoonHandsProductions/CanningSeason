# System Configuration Instructions

This document describes how to set up a workstation to be able to build and
deploy the game.

These instructions are based on [the Godot documentation for Android exporting](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

## Prerequisites for your own PC

1. Download and install [the OpenJDK distribution that is provided by Microsoft
   as an MSI file](https://docs.microsoft.com/en-us/java/openjdk/download). Make
   sure when you install it that it adds the JDK to the `PATH` and sets the
   `JAVA_HOME` variable; these options show up during the installation process.

1. Download and install [Android Studio](https://developer.android.com/studio).
 Run it at least once so it prompts you to accept the Android SDK licenses and then downloads them.

## Tablet configuration

You will have to make sure developer mode is enabled on your Android device.
Also, the first time it is connected via USB, you will need to click through a
dialog box to tell the device that you will allow the Android Debugger (ADB) to
communicate with the device.

## Godot Configuration

Make sure you have downloaded the export templates. You can check this by going to
Project&rightarrow;Export and selecting the Android target. If you don't have the
templates, you'll get a message at the bottom of the dialog box, which you can
click through to download them.

In the Godot Project, under Editor&rightarrow;Export&rightarrow;Android:

  - Set the debug keystore is to `../platform/debug.keystore`
  - Set the Android SDK path as follows:
      - In the lab, set it to `C:\Android`, which is where the team has put an
        Android SDK that the whole team can share no matter who is logged in.
      - On your own machine, set it to wherever Android Studio put it. It will
        probably be a path like `C:/Users/username/AppData/Local/Android/Sdk`.
        You can find it by opening or making a new project with Android Studio
        and accessing the SDK Manager in the upper-right of the IDE.
        
Make sure that, at the top level of the project, you have created a `build` folder and
an `android` folder within it.

## Exporting from Godot to Android APK

The first time you try to export any project from Godot, it will show an error at the bottom of the export window, prompting you to download the export templates. This is normal and only needs to be done once.

The export configuration is designed to export to `build/android/CanningSeason.apk` off of the root project directory. The first time you export, you will have to make these empty directories. They should of course not be in version control (and are ignored in the `.gitignore`) because they are purely generated files.
