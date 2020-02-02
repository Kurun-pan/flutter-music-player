import 'dart:math';
import 'package:flutter_music_player_app/data/music.dart';
import 'package:flutter_music_player_app/services/audio_player.dart';

class Musics {
  AudioPlayer _audioPlayer;
  List<Music> _musics;
  int _currentIndex = -1;

  Musics(this._musics) {
    _audioPlayer = new AudioPlayer();
  }

  List<Music> get tracks => _musics;
  int get length => _musics.length;
  int get trackNumber => _currentIndex + 1;

  setCurrentIndex(int index) {
    _currentIndex = index;
  }

  int get currentIndex => _currentIndex;

  Music get nextTrack {
    if (_currentIndex < length)
      _currentIndex++;
    if (_currentIndex >= length)
      return null;
    return _musics[_currentIndex];
  }

  Music get randomTrack {
    Random r = new Random();
    return _musics[r.nextInt(_musics.length)];
  }

  Music get prevTrack {
    if (_currentIndex > 0)
      _currentIndex--;
    if (_currentIndex < 0)
      return null;
    return _musics[_currentIndex];
  }

  AudioPlayer get audioPlayer => _audioPlayer;
}
