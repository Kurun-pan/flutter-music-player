import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/data/music.dart';
import 'package:flutter_music_player_app/pages/playing_page.dart';
import 'package:flutter_music_player_app/widgets/music_inherited.dart';
import 'package:flutter_music_player_app/widgets/main/music_lisview.dart';
import 'package:flutter_music_player_app/widgets/main/now_playing.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rootIW = MusicInheritedWidget.of(context);

    void goToNowPlaying(Music music, {bool nowPlayTap: false}) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new PlayingPage(
                    rootIW.musics,
                    music,
                    nowPlayTap: nowPlayTap,
                  )
          )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Flutter Music Player"),
      ),
      body: rootIW.isLoading
          ? new Center(child: new CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: new Scrollbar(child: new MusicListView()),
          ),
          nowPlayingArea(
              rootIW.musics.tracks[0],
                  () => goToNowPlaying(rootIW.musics.tracks[0])
          ),
        ],
      ),
    );
  }
}
