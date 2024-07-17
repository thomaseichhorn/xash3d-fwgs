#!/bin/bash

cd $GITHUB_WORKSPACE

ANDROID_COMMANDLINE_TOOLS_VER="11076708"
ANDROID_BUILD_TOOLS_VER="34.0.0"
ANDROID_PLATFORM_VER="android-34"
ANDROID_NDK_VER="26.3.11579264"

echo "Download JDK 17"
wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.7_7.tar.gz -qO jdk.tar.gz || exit 1
tar -xzf jdk.tar.gz
export JAVA_HOME=$GITHUB_WORKSPACE/jdk-17.0.7+7
export PATH=$PATH:$JAVA_HOME/bin

echo "Download hlsdk-portable"
git clone --depth 1 --recursive https://github.com/FWGS/hlsdk-portable -b mobile_hacks hlsdk || exit 1

echo "Download Android SDK"
mkdir -p sdk || exit 1
pushd sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMANDLINE_TOOLS_VER}_latest.zip -qO sdk.zip || exit 1
unzip -q sdk.zip || exit 1
mv cmdline-tools tools
mkdir -p cmdline-tools
mv tools cmdline-tools/tools
unset ANDROID_SDK_ROOT
export ANDROID_HOME=$GITHUB_WORKSPACE/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/tools/bin
popd

echo "Download all needed tools and Android NDK"
yes | sdkmanager --licenses > /dev/null 2>/dev/null # who even reads licenses? :)
sdkmanager --install build-tools\;${ANDROID_BUILD_TOOLS_VER} platform-tools platforms\;${ANDROID_PLATFORM_VER} ndk\;${ANDROID_NDK_VER}

echo "Download Xash3D FWGS Android source code"
git clone --depth 1 --recursive https://github.com/FWGS/xash3d-android-project -b gradle android || exit 1
pushd android/app/src/main/cpp

mv xash3d-fwgs xash3d-fwgs-sub
ln -s $GITHUB_WORKSPACE xash3d-fwgs
echo "Installed Xash3D FWGS source symlink"

mv hlsdk-portable hlsdk-portable-sub
ln -s $GITHUB_WORKSPACE/hlsdk hlsdk-portable
echo "Installed hlsdk-portable source symlink"

popd
