package com.example.flutter_music_player_app

import android.content.ContentResolver
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

class MusicFinder(val contentResolver: ContentResolver) {
    private val musics: MutableList<Music> = ArrayList()
    private val albumMap = HashMap<Long, String>()
    private val audioPath = HashMap<Long, String>()

    fun prepare() {
        loadAlbumArt()
        loadAudioPath()

        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val cur = contentResolver.query(uri, null,
                MediaStore.Audio.Media.IS_MUSIC + " = 1", null, null)
                ?: return
        if (!cur.moveToFirst())
            return

        val artistColumn = cur.getColumnIndex(MediaStore.Audio.Media.ARTIST)
        val titleColumn = cur.getColumnIndex(MediaStore.Audio.Media.TITLE)
        val albumColumn = cur.getColumnIndex(MediaStore.Audio.Media.ALBUM)
        val albumArtColumn = cur.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)
        val durationColumn = cur.getColumnIndex(MediaStore.Audio.Media.DURATION)
        val idColumn = cur.getColumnIndex(MediaStore.Audio.Media._ID)
        val trackIdColumn = cur.getColumnIndex(MediaStore.Audio.Media.TRACK)
        val musicDirPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC).absolutePath
        do {
            val trackIdStr = cur.getString(trackIdColumn)
            var trackId = 0
            if (!trackIdStr.isEmpty())
                trackId = trackIdStr.toInt()

            val music = Music(
                    cur.getLong(idColumn),
                    cur.getString(artistColumn),
                    cur.getString(titleColumn),
                    cur.getString(albumColumn),
                    cur.getLong(durationColumn),
                    audioPath[cur.getLong(idColumn)],
                    albumMap[cur.getLong(albumArtColumn)],
                    trackId.toLong())
            if (music.uri!!.startsWith(musicDirPath))
                musics.add(music)
        } while (cur.moveToNext())

        cur.close()
    }

    private fun loadAlbumArt() {
        val cursor = contentResolver.query(
                MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                arrayOf(MediaStore.Audio.Albums._ID, MediaStore.Audio.Albums.ALBUM_ART),
                null,
                null,
                null)

        if (cursor!!.moveToFirst()) {
            do {
                val id = cursor.getLong(cursor.getColumnIndex(MediaStore.Audio.Albums._ID))
                val path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART))
                Log.d("debug", "id = ${id}, path = ${path}")
                //mAlbumMap[id] = path
            } while (cursor.moveToNext())
        }
        cursor.close()
    }

    private fun loadAudioPath() {
        val cursor = contentResolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.DATA),
                null,
                null,
                null)
        if (cursor!!.moveToFirst()) {
            do {
                val id = cursor.getLong(cursor.getColumnIndex(MediaStore.Audio.Media._ID))
                val path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.DATA))
                audioPath[id] = path
            } while (cursor.moveToNext())
        }
        cursor.close()
    }

    val randomMusic: Music?
        get() = if (musics.size <= 0) null else musics[Random().nextInt(musics.size)]

    val allMusics: List<Music>
        get() = musics

    inner class Music {
        var id: Long
        var artist: String
        var title: String
        var album: String
        var albumId: Long = 0
        var duration: Long
        var uri: String?
        var albumArt: String? = null
        var trackId: Long

        constructor(id: Long, artist: String, title: String, album: String,
                    duration: Long, uri: String?, albumArt: String?, trackId: Long) {
            this.id = id
            this.artist = artist
            this.title = title
            this.album = album
            this.duration = duration
            this.uri = uri
            this.albumArt = albumArt
            this.trackId = trackId
        }

        fun toMap(): HashMap<String, Any?> {
            val songsMap = HashMap<String, Any?>()
            songsMap["id"] = id
            songsMap["artist"] = artist
            songsMap["title"] = title
            songsMap["album"] = album
            songsMap["albumId"] = albumId
            songsMap["duration"] = duration
            songsMap["uri"] = uri
            songsMap["albumArt"] = albumArt
            songsMap["trackId"] = trackId
            return songsMap
        }
    }
}
