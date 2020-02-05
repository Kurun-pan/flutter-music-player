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

  Future<dynamic> play(String url, {bool isLocal: false}) =>
      _channel.invokeMethod('play', {"url": url, "isLocal": isLocal});

  Future<dynamic> pause() =>
      _channel.invokeMethod('pause');

  Future<dynamic> stop() =>
      _channel.invokeMethod('stop');

  Future<dynamic> mute(bool muted) =>
      _channel.invokeMethod('mute', muted);

  Future<dynamic> seek(double seconds) =>
      _channel.invokeMethod('seek', seconds);

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
    var completer = new Completer();
    List<dynamic> musics = await _channel.invokeMethod('getMusics', null);
    print(musics.runtimeType);

    completer.complete(musics.map((m) => new Music.fromMap(m)).toList());
    return completer.future;

    // example music list
    /*
    List<Music> musics = [
      new Music(0, "artist", "a music", "sample album", 0, 100, "uri", null, 0),
      new Music(1, "artist", "b music", "sample album", 0, 100, "uri", null, 1),
    ];
    return musics;
     */
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
