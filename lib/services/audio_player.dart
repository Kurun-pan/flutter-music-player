import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player_app/data/music.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

class AudioPlayer {
  static const MethodChannel _channel = const MethodChannel('com.example/audio_player');

  TimeChangeHandler durationHandler;
  TimeChangeHandler positionHandler;
  VoidCallback startHandler;
  VoidCallback completionHandler;
  ErrorHandler errorHandler;

  AudioPlayer() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  Future<dynamic> play(String url, {bool isLocal: false}) {
      // todo: support other plaftorms
      if (Platform.isAndroid)
        return _channel.invokeMethod('play', {"url": url, "isLocal": isLocal});
      else
        return null;
  }

  Future<dynamic> pause() {
      // todo: support other plaftorms
      if (Platform.isAndroid)
        return _channel.invokeMethod('pause');
      else
        return null;
  }

  Future<dynamic> stop() {
      // todo: support other plaftorms
      if (Platform.isAndroid)
        return _channel.invokeMethod('stop');
      else
        return null;
  }

  Future<dynamic> mute(bool muted) {
      // todo: support other plaftorms
      if (Platform.isAndroid)
        return _channel.invokeMethod('mute', muted);
      else
        return null;
  }

  Future<dynamic> seek(double seconds) {
      // todo: support other plaftorms
      if (Platform.isAndroid)
        return _channel.invokeMethod('seek', seconds);
      else
        return null;
  }

  void setDurationHandler(TimeChangeHandler handler) {
    durationHandler = handler;
  }

  void setPositionHandler(TimeChangeHandler handler) {
    positionHandler = handler;
  }

  void setStartHandler(VoidCallback callback) {
    startHandler = callback;
  }

  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  static Future<dynamic> getMusics() async {
    if (Platform.isAndroid) {
      var completer = new Completer();
      List<dynamic> musics = await _channel.invokeMethod('getMusics', null);
      print(musics.runtimeType);

      completer.complete(musics.map((m) => new Music.fromMap(m)).toList());
      return completer.future;
    } else {
      // todo: support other plaftorms
      // example music list
      List<Music> musics = [
        new Music(0, "aaa", "a music", "sample album", 0, 100, "uri", null, 0),
        new Music(1, "bbb", "b music", "sample album", 0, 100, "uri", null, 1),
        new Music(2, "ccc", "c music", "sample album", 0, 100, "uri", null, 2),
        new Music(3, "ddd", "d music", "sample album", 0, 100, "uri", null, 3),
      ];
      return musics;
    }
  }

  Future platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "audio.onDuration":
        final duration = new Duration(milliseconds: call.arguments);
        if (durationHandler != null)
          durationHandler(duration);
        break;
      case "audio.onCurrentPosition":
        if (positionHandler != null)
          positionHandler(new Duration(milliseconds: call.arguments));
        break;
      case "audio.onStart":
        if (startHandler != null)
          startHandler();
        break;
      case "audio.onComplete":
        if (completionHandler != null)
          completionHandler();
        break;
      case "audio.onError":
        if (errorHandler != null)
          errorHandler(call.arguments);
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }
}
