import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_music_player_app/data/music.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

class MusicFinder {
  static const MethodChannel _channel = const MethodChannel('music_finder');
  ErrorHandler _errorHandler;
  bool _handlePermissions = true;
  bool _executeAfterPermissionGranted = true;

  MusicFinder() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  void setErrorHandler(ErrorHandler handler) {
    _errorHandler = handler;
  }

  MusicFinder setHandlePermissions(bool handlePermissions) {
    _handlePermissions = handlePermissions;
    return this;
  }

  MusicFinder setExecuteAfterPermissionGranted(
      bool executeAfterPermissionGranted) {
    _executeAfterPermissionGranted = executeAfterPermissionGranted;
    return this;
  }

  static Future<dynamic> getMusics() async {
    // TODO: support cross platform
    /*
    var completer = new Completer();
    Map params = <String, dynamic>{
      "handlePermissions": true,
      "executeAfterPermissionGranted": true,
    };

    List<dynamic> musics = await _channel.invokeMethod('getMusics', params);
    print(musics.runtimeType);

    completer.complete(musics.map((m) => new Music.fromMap(m)).toList());
    return completer.future;
     */

    // example music list
    List<Music> musics = [
      new Music(0, "artist", "a music", "sample album", 0, 100, "uri", null, 0),
      new Music(1, "artist", "b music", "sample album", 0, 100, "uri", null, 1),
    ];
    return musics;
  }

  Future platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "music_finder.onError":
        if (_errorHandler != null)
          _errorHandler(call.arguments);
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }
}
