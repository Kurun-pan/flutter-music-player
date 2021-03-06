class Music {
  int id;
  String artist;
  String title;
  String album;
  int albumId;
  int duration;
  String uri;
  String albumArt;
  int trackId;

  Music(this.id, this.artist, this.title, this.album, this.albumId,
      this.duration, this.uri, this.albumArt, this.trackId);

  Music.fromMap(Map m) {
    id = m["id"];
    artist = m["artist"];
    title = m["title"];
    album = m["album"];
    albumId = m["albumId"];
    duration = m["duration"];
    uri = m["uri"];
    albumArt = m["albumArt"];
    trackId = m["trackId"];
  }
}
