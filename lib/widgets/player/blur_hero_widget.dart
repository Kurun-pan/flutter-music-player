import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/data/music.dart';

Widget blurHeroWidget(Music music) {
  var f = music.albumArt == null ? null : new File.fromUri(Uri.parse(music.albumArt));

  return new Hero(
    tag: music.artist,
    child: new Container(
      child: f != null
          ? new Image.file(
              f,
              fit: BoxFit.cover,
              color: Colors.black54,
              colorBlendMode: BlendMode.darken,
            )
          : new Image(
              image: new AssetImage("assets/background.jpg"),
              color: Colors.black54,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
            ),
    ),
  );
}
