import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_app/data/music.dart';
import 'package:flutter_music_player_app/services/audio_player.dart';
import 'package:flutter_music_player_app/data/musics.dart';
import 'package:flutter_music_player_app/widgets/player/album_ui.dart';
import 'package:flutter_music_player_app/widgets/player/blur_hero_widget.dart';
import 'package:flutter_music_player_app/widgets/player/blur_filter.dart';
import 'package:flutter_music_player_app/widgets/player/custom_icon_button.dart';

enum PlayerState { stopped, playing, paused }

class PlayingPage extends StatefulWidget {
  final Music _music;
  final Musics musics;
  final bool nowPlayTap;

  PlayingPage(this.musics, this._music, {this.nowPlayTap});

  @override
  _PlayingState createState() => new _PlayingState();
}

class _PlayingState extends State<PlayingPage> {
  AudioPlayer audioPlayer;
  Duration duration;
  Duration position;
  PlayerState playerState;
  Music music;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  @override
  initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
    play(widget.musics.nextTrack);
  }

  initPlayer() async {
    if (audioPlayer == null)
      audioPlayer = widget.musics.audioPlayer;

    setState(() {
      music = widget._music;
      if (widget.nowPlayTap == null || widget.nowPlayTap == false) {
        if (playerState != PlayerState.stopped)
          stop();
      }
      play(music);
    });
    audioPlayer.setDurationHandler((d) => setState(() {
          duration = d;
        }));

    audioPlayer.setPositionHandler((p) => setState(() {
          position = p;
        }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() => position = duration);
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play(Music m) async {
    if (m != null) {
      final result = await audioPlayer.play(m.uri, isLocal: true);
      if (result == 1)
        setState(() {
          playerState = PlayerState.playing;
          music = m;
        });
    }
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1)
      setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  Future next(Musics m) async {
    stop();
    play(m.nextTrack);
  }

  Future prev(Musics m) async {
    stop();
    play(m.prevTrack);
  }

  Future mute(bool muted) async {
    final result = await audioPlayer.mute(muted);
    if (result)
      setState(() => isMuted = muted);
  }

  void changeTrack(int index) {
    //print("index = $index");
    if (index > widget.musics.currentIndex)
      next(widget.musics);
    else
      prev(widget.musics);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildPlayer() => new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(mainAxisSize: MainAxisSize.min, children: [
          new Column(
            children: <Widget>[
              new Text(
                music.title,
                style: Theme.of(context).textTheme.headline,
              ),
              new Text(
                music.artist,
                style: Theme.of(context).textTheme.caption,
              ),
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              )
            ],
          ),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new CustomIconButton(Icons.skip_previous, () => prev(widget.musics)),
            new CustomIconButton(isPlaying ? Icons.pause : Icons.play_arrow,
                isPlaying ? () => pause() : () => play(widget._music)),
            new CustomIconButton(Icons.skip_next, () => next(widget.musics)),
          ]),
          duration == null
              ? new Container()
              : new Slider(
                  value: position?.inMilliseconds?.toDouble() ?? 0,
                  onChanged: (double value) =>
                      audioPlayer.seek((value / 1000).roundToDouble()),
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()),
          new Row(mainAxisSize: MainAxisSize.min, children: [
            new Text(
                position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : duration != null ? durationText : '',
                style: new TextStyle(fontSize: 24.0))
          ]),
          new Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new IconButton(
                  icon: isMuted
                      ? new Icon(
                          Icons.headset,
                          color: Theme.of(context).unselectedWidgetColor,
                        )
                      : new Icon(Icons.headset_off,
                          color: Theme.of(context).unselectedWidgetColor),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    mute(!isMuted);
                  }),
              new IconButton(
                  icon: new Icon(
                      Icons.repeat,
                      color: Theme.of(context).unselectedWidgetColor,
                  ), onPressed: null)
            ],
          ),
        ]));

    var playerUI = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          new AlbumUI(widget.musics, music, duration, position, changeTrack),
          new Material(
            child: _buildPlayer(),
            color: Colors.transparent,
          ),
        ]);

    return new Scaffold(
      body: new Container(
        color: Theme.of(context).backgroundColor,
        child: new Stack(
          fit: StackFit.expand,
          children: <Widget>[blurHeroWidget(music), blurFilter(), playerUI],
        ),
      ),
    );
  }
}
