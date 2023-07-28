# ailia_flutter

A flutter binding for ailia.

# Setup flutter

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

# Bind ailia C API via ffigen

## Install ffigen

Add ffigen to pubspec.yaml.

https://blog.logrocket.com/dart-ffi-native-libraries-flutter/

## Place ailia header

Place ailia.h to header folder.

## Install llvm

```
brew install llvm
```

## Convert

```
dart run ffigen
```

# call ailia API

## Predict API

```
TBD
```

# Documents

- https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/01_chapter0_aboutme
- https://docs.flutter.dev/platform-integration/macos/c-interop
- https://blog.logrocket.com/dart-ffi-native-libraries-flutter/
