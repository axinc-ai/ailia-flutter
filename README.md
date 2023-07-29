# ailia_flutter

A flutter binding for ailia.

# Test environment

- macOS 13.4

# Setup flutter

This step is not necessary if flutter is already installed.

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

I specified 15 because the build failed on M1 Mac with llvm.

```
arch -arm64 brew install llvm@15
```

Add llvm path to pubspec.yaml.

```
  llvm-path:
    - '/usr/local/opt/llvm@15'
```

## Convert

```
dart run ffigen
```

# Call ailia API

## Predict API

```
TBD
```

# Documents

- https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/01_chapter0_aboutme
- https://docs.flutter.dev/platform-integration/macos/c-interop
- https://blog.logrocket.com/dart-ffi-native-libraries-flutter/
