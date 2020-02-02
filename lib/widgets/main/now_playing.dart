import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/data/music.dart';
import 'package:flutter_music_player_app/widgets/player/custom_icon_button.dart';

Widget nowPlayingArea(Music music, VoidCallback callback) {
  return Container(
      margin: EdgeInsets.all(16.0),
      child: Row(    // 1行目
        children: <Widget>[
          Expanded(  // 2.1列目
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(  // 3.1.1行目
                  margin: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    music.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                    ),
                  ),
                ),
                Container(  // 3.1.2行目
                  child: Text(
                    music.artist,
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomIconButton(  // 2.2列目
            Icons.play_circle_outline,
            callback,
          ),
        ],
      )
  );
}
