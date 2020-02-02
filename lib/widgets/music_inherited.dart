import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/data/musics.dart';

class MusicInheritedWidget extends InheritedWidget {
  final Musics musics;
  final bool isLoading;

  const MusicInheritedWidget(this.musics, this.isLoading, child)
      : super(child: child);

  static MusicInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MusicInheritedWidget>();
  }

  @override
  bool updateShouldNotify(MusicInheritedWidget oldWidget) =>
      musics != oldWidget.musics || isLoading != oldWidget.isLoading;
}
