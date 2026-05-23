{ pkgs, ... }:

let
  # Compose Android SDK with all required components
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    # Command-line tools version
    cmdLineToolsVersion = "11.0";

    # Platform tools (adb, fastboot, etc.) - using default version

    # Build tools
    buildToolsVersions = [ "35.0.0" ];

    # Include Android platforms
    platformVersions = [ "35" ];

    # Include system images for emulator
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];

    # Include emulator (using latest available version)
    includeEmulator = true;
    emulatorVersion = "36.4.2";

    # Include NDK if needed (optional, comment out if not needed)
    # includeNDK = true;
    # ndkVersions = [ "26.1.10909125" ];

    # Include additional packages
    includeExtras = [
      "extras;google;gcm"
    ];
  };

  # Android SDK root
  androidSdk = androidComposition.androidsdk;

in
{
  home.packages = with pkgs; [
    # Java JDK 17 for Android development
    jdk17

    # Android SDK with all components
    androidSdk

    # Gradle for building Android projects
    gradle

    # scrcpy for screen mirroring and control
    scrcpy

    # Android Studio (optional, comment out if you prefer command-line only)
    # android-studio
  ];

  # Set up environment variables
  home.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    JAVA_HOME = "${pkgs.jdk17}";
  };

  # Add Android SDK tools to PATH
  home.sessionPath = [
    "${androidSdk}/libexec/android-sdk/tools"
    "${androidSdk}/libexec/android-sdk/tools/bin"
    "${androidSdk}/libexec/android-sdk/platform-tools"
    "${androidSdk}/libexec/android-sdk/build-tools/35.0.0"
    "${androidSdk}/libexec/android-sdk/emulator"
  ];

  # Create helper scripts
  home.file.".local/bin/android-emulator" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Helper script to launch Android emulator
      # Usage: android-emulator <avd-name>

      AVD_NAME=''${1:-Pixel_5_API_35}

      echo "Launching Android Emulator: $AVD_NAME"
      ${androidSdk}/libexec/android-sdk/emulator/emulator -avd "$AVD_NAME" "$@"
    '';
  };

  home.file.".local/bin/android-create-avd" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Helper script to create an Android Virtual Device
      # Usage: android-create-avd <avd-name> [device-type] [api-level]

      AVD_NAME=''${1:-Pixel_5_API_35}
      DEVICE=''${2:-pixel_5}
      API_LEVEL=''${3:-35}

      echo "Creating AVD: $AVD_NAME"
      echo "Device: $DEVICE"
      echo "API Level: $API_LEVEL"

      ${androidSdk}/libexec/android-sdk/cmdline-tools/latest/bin/avdmanager create avd \
        --name "$AVD_NAME" \
        --package "system-images;android-$API_LEVEL;google_apis_playstore;x86_64" \
        --device "$DEVICE" \
        --force

      echo ""
      echo "AVD created successfully!"
      echo "Launch with: android-emulator $AVD_NAME"
    '';
  };
}
