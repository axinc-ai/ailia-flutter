// for ailia SDK
import 'package:path/path.dart' as p;
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart'; // malloc
import 'dart:typed_data';
import 'package:ailia_flutter/ffi/ailia.dart' as ailia_dart;
import 'package:ailia_flutter/ffi/ailia_audio.dart' as ailia_audio_dart;
import 'category.dart';

String _getPath() {
  if (Platform.isAndroid || Platform.isLinux){
    return 'libailia.so';
  }
  if (Platform.isMacOS){
    return 'libailia.dylib';
  }
  if (Platform.isWindows){
    return 'ailia.dll';
  }
  return 'internal';
}

DynamicLibrary ailiaGetLibrary(){
    final DynamicLibrary library;
    if (Platform.isIOS){
      library = DynamicLibrary.process();
    }else{
      library = DynamicLibrary.open(_getPath());
    }
    return library;
}

void ailiaEnvironmentSample(){
    final ailia = ailia_dart.ailiaFFI(ailiaGetLibrary());

    final Pointer<Uint32> count = malloc<Uint32>();
    count.value = 0;
    ailia.ailiaGetEnvironmentCount(count);
    print("Environment ${count.value}");

    for (int env_idx = 0; env_idx < count.value; env_idx++){
      Pointer<Pointer<ailia_dart.AILIAEnvironment>> pp_env = malloc<Pointer<ailia_dart.AILIAEnvironment>>();
      ailia.ailiaGetEnvironment(pp_env, env_idx, ailia_dart.AILIA_ENVIRONMENT_VERSION);
      Pointer<ailia_dart.AILIAEnvironment> p_env = pp_env.value;
      print("Backend ${p_env.ref.backend}");
      print("Name ${p_env.ref.name.cast<Utf8>().toDartString()}");
      malloc.free(pp_env);
    }
    malloc.free(count);
}

String ailiaPredictSample(File onnx_file, ByteData data){
  final ailia = ailia_dart.ailiaFFI(ailiaGetLibrary());

  Pointer<Pointer<ailia_dart.AILIANetwork>> pp_ailia = malloc<Pointer<ailia_dart.AILIANetwork>>();
  int status = ailia.ailiaCreate(pp_ailia, ailia_dart.AILIA_ENVIRONMENT_ID_AUTO, ailia_dart.AILIA_MULTITHREAD_AUTO);
  if (status != ailia_dart.AILIA_STATUS_SUCCESS){
    print("ailiaCreate failed ${status}");
    return "Error";
  }

  String onnx_path = onnx_file.path;
  print("onnx path : ${onnx_path}");
  status = ailia.ailiaOpenWeightFileA(pp_ailia.value, onnx_path.toNativeUtf8().cast<Int8>());
  if (status != ailia_dart.AILIA_STATUS_SUCCESS){
    print("ailiaOpenWeightFileA failed ${status}");
    return "Error";
  }

  const int num_class = 1000;
  const int image_size = 224;
  const int image_channels = 3;

  Pointer<Float> dest = malloc<Float>(1000);
  Pointer<Float> src = malloc<Float>(image_size * image_size * image_channels);

  List pixel = data.buffer.asUint8List().toList();

  List mean = [0.485, 0.456, 0.406];
  List std = [0.229, 0.224, 0.225];

  for (int y = 0; y < image_size; y++){
    for (int x = 0; x < image_size; x++){
      for (int rgb = 0; rgb < 3; rgb++){
        src[y * image_size + x + rgb * image_size * image_size] = (pixel[(image_size * y + x) * 4 + rgb] / 255.0 - mean[rgb])/std[rgb];
      }
    }
  }

  int sizeof_float = 4;
  status = ailia.ailiaPredict(pp_ailia.value, dest.cast<Void>(), sizeof_float * num_class, src.cast<Void>(), sizeof_float * image_size * image_size * image_channels);

  double max_prob = 0.0;
  int max_i = 0;
  for (int i = 0; i < num_class; i++){
    if (max_prob < dest[i]){
      max_prob = dest[i];
      max_i = i;
    }
  }

  malloc.free(dest);
  malloc.free(src);

  Pointer<ailia_dart.AILIANetwork> net = pp_ailia.value;
  ailia.ailiaDestroy(net);
  malloc.free(pp_ailia);

  return "Class : ${max_i} ${imagenet_category[max_i]} Confidence : ${max_prob}";
}

