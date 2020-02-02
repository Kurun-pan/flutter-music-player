import 'dart:io';
import 'package:flutter_music_player_app/data/musics.dart';
import 'package:flutter_music_player_app/pages/playing_page.dart';
import 'package:flutter_music_player_app/widgets/music_inherited.dart';
import 'package:flutter_music_player_app/widgets/main/circle_avatar.dart';
import 'package:flutter/material.dart';

class MusicListView extends StatelessWidget {
  final List<MaterialColor> _colors = Colors.primaries;

  @override
  Widget build(BuildContext context) {
    final rootIW = MusicInheritedWidget.of(context);
    Musics musics = rootIW.musics;

    return new ListView.builder(
      itemCount: musics.tracks.length,
      itemBuilder: (context, int index) {
        final MaterialColor color = _colors[index % _colors.length];
        var m = musics.tracks[index];
        var artFile =
            m.albumArt == null ? null : new File.fromUri(Uri.parse(m.albumArt));

        return new ListTile(
          dense: false,
          leading: new Hero(
            child: avatar(artFile, m.title, color),
            tag: m.title,
          ),
          title: new Text(m.title),
          subtitle: new Text(
            m.artist,
            style: Theme.of(context).textTheme.caption,
          ),
          onTap: () {
            musics.setCurrentIndex(index);
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new PlayingPage(musics, m)
                )
            );
          },
        );
      },
    );
  }
}
