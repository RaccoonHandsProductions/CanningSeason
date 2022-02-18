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
   This will install the latest Android SDK as a silent part of the process. 

## Tablet configuration

You will have to make sure developer mode is enabled on your Android device.
Also, the first time it is connected via USB, you will need to click through a
dialog box to tell the device that you will allow the Android Debugger (ADB) to
communicate with the device.

## Godot Configuration

In the Godot Project, under Editor&rightarrow;Export&rightarrow;Android:

  - Set the debug keystore is to `../platform/debug.keystore`
  - Set the Android SDK path as follows:
      - In the lab, set it to `C:\Android`, which is where the team has put an
        Android SDK that the whole team can share no matter who is logged in.
      - On your own machine, set it to wherever Android Studio put it. It will
        probably be a path like `C:/Users/username/AppData/Local/Android/Sdk`.
        You can find it by opening or making a new project with Android Studio
        and accessing the SDK Manager in the upper-right of the IDE.

