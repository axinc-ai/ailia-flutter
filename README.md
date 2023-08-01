# ailia Flutter Sample

A flutter binding for ailia.

# Test environment

## macOS

- macOS 13.4
- flutter 3.10.6
- vscode 1.79.2
- flutter extension 3.68.0

## Windows

- windows 10
- flutter 3.10.6
- vscode 1.80.1
- flutter extension 3.68.0

# Setup flutter

This step is not necessary if flutter is already installed.

Reference : https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/01_chapter0_aboutme

## Install flutter

Download flutter sdk and unzip.

https://docs.flutter.dev/get-started/install

Add to path to .zshrc.

```
export PATH="/Users/xxx/flutter/bin:$PATH"
```

## Install vscode extension

1. Install flutter extension.
2. Create new project (flutter: new project) from view -> command pallet.
3. Push run from menu button.

# Bind ailia C API via ffigen (Optional)

The steps below are done with ax and the dart interface files are included in this repository. Therefore, execution is not mandatory.

## Install ffigen

Add ffigen to pubspec.yaml.

https://blog.logrocket.com/dart-ffi-native-libraries-flutter/

## Place ailia header

Place ailia.h to native folder.

## Install llvm

llvm is required to run ffi. The official tutorial says to run brew install llvm. But when calling brew install llvm, the clang arch does not match.

```
tried: '/usr/local/opt/llvm@15/lib/libclang.dylib' (mach-o file, but is an incompatible architecture (have 'x86_64', need 'arm64')),
```

https://stackoverflow.com/questions/71882029/mach-o-file-but-is-an-incompatible-architecture-have-arm64-need-x86-64-i

So try to install llvm on arm architecture. I specified llvm@15 because the build failed on M1 Mac with llvm.

```
arch -arm64 brew install llvm@15
```

However, this command also installs the x86_64 version of clang. Therefore, changed flutter SDK to x86_64 version.

Finally, add llvm path to pubspec.yaml.

```
  llvm-path:
    - '/usr/local/opt/llvm@15'
```

## Convert

Convert ailia.h to ailia.dart with the command below.

```
dart run ffigen --config ffigen_ailia.yaml
dart run ffigen --config ffigen_ailia_audio.yaml
```

Converting a struct will result in a build error, so the generated class needs to be marked final.

https://github.com/dart-lang/sdk/issues/51787

Exported file is [lib/ffi/ailia.dart](lib/ffi/ailia.dart).

# Call ailia API

## Add library to project file

### macOS

Put libailia.dylib to macos folder. Open macos/Runner.xcworkspace. Regist libailia.dylib by following steps.

https://docs.flutter.dev/platform-integration/macos/c-interop

![tutorial](tutorial/macos.png)

### iOS

Put libailia.a to ios folder. Open ios/Runner.xcworkspace. Regist libailia.a, libc++.tbd, Accelerate.framework, MetalPerformanceShader to Frameworks.

https://docs.flutter.dev/platform-integration/ios/c-interop

![tutorial](tutorial/ios.png)

If you don't call libailia.a at all, it will be erased by linking and symbol not found by dlopen. Add ailia_link.c and call ailiaGetVersion() as a dummy to avoid this.

```
//
//  ailia_link.c
//  Runner
//
//  Created by Kazuki Kyakuno on 2023/07/31.
//

#include "ailia_link.h"
#include "ailia.h"

// Dummy link to keep libailia.a from being deleted

void test(void){
    ailiaGetVersion();
}
```

### Android

Put libailia.so to android/app/src/jniLibs/[arm64-v8a, armeabi-v7a].

https://docs.flutter.dev/platform-integration/android/c-interop

![tutorial](tutorial/android.png)

### Windows

Copy ailia.dll to build/windows/runner/Debug.

![tutorial](tutorial/windows.png)

## Add model to assets folder

Put resnet18.onnx and clock.jpg to assets folder. Add these files to pubspec.yaml.　By the way, already registered in the project in the sample.

## Predict

When you run this sample, resnet18 classifies what the image is.

![resnet18](tutorial/resnet18.png)

The inference code is below.

[lib/ailia_predict_sample.dart](lib/ailia_predict_sample.dart)

# Trouble shooting

## iOS and macOS pod error

Please run below command on Rosetta2.

```
arch -x86_64 pod update
arch -x86_64 pod install
```
# Reference

- https://blog.logrocket.com/dart-ffi-native-libraries-flutter/
