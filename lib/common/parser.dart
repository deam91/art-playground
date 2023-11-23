import 'dart:ffi';
import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// C header typedef:
typedef ParserC = Pointer<Utf8> Function(Pointer<Utf8> svg);

// Dart header typedef
typedef ParserDart = Pointer<Utf8> Function(Pointer<Utf8> command);

String getPath() {
  var libraryPath =
      path.join(Directory.current.path, 'assets/parser', 'parser.so');
  if (Platform.isMacOS) {
    libraryPath =
        path.join(Directory.current.path, 'assets/parser', 'parser.dylib');
  } else if (Platform.isWindows) {
    libraryPath = path.join(
        Directory.current.path, 'assets/parser', 'Debug', 'parser.dll');
  }
  return libraryPath;
}

call(String svgString) {
  final libraryPath = getPath();
  final dylib = DynamicLibrary.open(libraryPath);
  final getPoints = dylib.lookupFunction<ParserC, ParserDart>('getPoints');
  print(getPoints(svgString.toNativeUtf8()));
}
