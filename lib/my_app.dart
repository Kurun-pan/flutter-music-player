import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/pages/main_page.dart';
import 'package:flutter_music_player_app/data/musics.dart';
import 'package:flutter_music_player_app/widgets/music_inherited.dart';
import 'package:flutter_music_player_app/services/music_finder.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Musics musics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    musics.audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return new MusicInheritedWidget(musics, _isLoading, new MainPage());
  }

  initPlatformState() async {
    _isLoading = true;

    var musicFiles;
    try {
      musicFiles = await MusicFinder.getMusics();
    } catch (e) {
      print("MusicFInder Failed: '${e.message}'.");
    }
    print(musicFiles);

    if (!mounted)
      return;

    setState(() {
      musics = new Musics((musicFiles));
      _isLoading = false;
    });
  }
}
