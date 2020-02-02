import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);

class AudioPlayer {
  static const MethodChannel _channel = const MethodChannel('audio_player');

  TimeChangeHandler durationHandler;
  TimeChangeHandler positionHandler;
  VoidCallback startHandler;
  VoidCallback completionHandler;
  ErrorHandler errorHandler;

  AudioPlayer() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  // TODO: implementation!!
  Future<dynamic> play(String url, {bool isLocal: false}) => null;
      //_channel.invokeMethod('play', {"url": url, "isLocal": isLocal});

  Future<dynamic> pause() => null; //_channel.invokeMethod('pause');

  Future<dynamic> stop() => null; //_channel.invokeMethod('stop');

  Future<dynamic> mute(bool muted) => null; //_channel.invokeMethod('mute', muted);

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

  //static Future<String> get platformVersion =>
  //    _channel.invokeMethod('getPlatformVersion');

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
