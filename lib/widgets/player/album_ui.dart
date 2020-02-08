import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_music_player_app/data/musics.dart';
import 'package:flutter_music_player_app/data/music.dart';

class AlbumUI extends StatefulWidget {
  final Musics musics;
  final Music music;
  final Duration position;
  final Duration duration;
  final void Function(int) changeTrackHandler;

  AlbumUI(this.musics, this.music, this.duration, this.position, this.changeTrackHandler);

  @override
  AlbumUIState createState() => new AlbumUIState();
}

class AlbumUIState extends State<AlbumUI> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;

  @override
  initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 1));
    animation = new CurvedAnimation(
        parent: animationController, curve: Curves.elasticOut);
    animation.addListener(() => this.setState(() {}));
    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var f = widget.music.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(widget.music.albumArt));

    final double height = 280.0;
    var myHero = new Hero(
      tag: widget.music.title,
      child: new Material(
          borderRadius: new BorderRadius.circular(5.0),
          elevation: 5.0,
          child: new Swiper(
            itemBuilder: (BuildContext context, int index) {
              if (f != null)
                return new Image.file(
                  f,
                  fit: BoxFit.cover,
                  height: height,
                  gaplessPlayback: true,
                );
              else
                return new Image.asset(
                  "assets/music_cover.jpg",
                  fit: BoxFit.fill,
                  height: height,
                  gaplessPlayback: false,
                );
            },
            onIndexChanged: (int index) {
              if (widget.changeTrackHandler != null)
                widget.changeTrackHandler(index);
            },
            itemCount: widget.musics.length,
            viewportFraction: 1.0,
            scale: 1.0,
          )
      ),
    );

    return new SizedBox.fromSize(
      size: new Size(animation.value * height, animation.value * height),
      child: new Stack(
        children: <Widget>[
          myHero,
          /*
          new Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 0.8),
            child: new Material(
              borderRadius: new BorderRadius.circular(5.0),
              child: new Stack(children: [
                new LinearProgressIndicator(
                    value: 1.0,
                    valueColor: new AlwaysStoppedAnimation(
                        Theme.of(context).buttonColor)),
                new LinearProgressIndicator(
                  value: widget.position != null &&
                          widget.position.inMilliseconds > 0
                      ? (widget.position?.inMilliseconds?.toDouble() ?? 0.0) /
                          (widget.duration?.inMilliseconds?.toDouble() ?? 0.0)
                      : 0.0,
                  valueColor:
                      new AlwaysStoppedAnimation(Theme.of(context).cardColor),
                  backgroundColor: Theme.of(context).buttonColor,
                ),
              ]),
            ),
          ),
          */
        ],
      ),
    );
  }
}
