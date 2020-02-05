package com.example.flutter_music_player_app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.IOException
import java.util.*

class MainActivity: FlutterActivity() {
    companion object {
        private const val REQUEST_PERMISSION_READ_EXTERNAL_STORAGE = 1
        private const val CHANNEL = "com.example/audio_player"
        private const val METHOD_PLAY = "play"
        private const val METHOD_PAUSE = "pause"
        private const val METHOD_STOP = "stop"
        private const val METHOD_MUTE = "mute"
        private const val METHOD_SEEK = "seek"
        private const val METHOD_GET_MUSICS = "getMusics"
    }

    private val audioManager: AudioManager? = null
    private var mediaPlayer: MediaPlayer? = null
    private val handler: Handler = Handler()
    private var pendingResult: MethodChannel.Result? = null
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { methodCall: MethodCall, result: MethodChannel.Result ->
            if (methodCall.method == METHOD_PLAY) {
                val url = methodCall.argument<String>("url").toString()
                play(url)
                result.success(1)
            }
            else if (methodCall.method == METHOD_PAUSE) {
                pause()
                result.success(1)
            }
            else if (methodCall.method == METHOD_STOP) {
                stop()
                result.success(1)
            }
            else if (methodCall.method == METHOD_MUTE) {
                val muted: Boolean = methodCall.arguments()
                mute(muted)
                result.success(1)
            }
            else if (methodCall.method == METHOD_SEEK) {
                val position: Double = methodCall.arguments()
                seek(position)
                result.success(1)
            }
            else if (methodCall.method == METHOD_GET_MUSICS) {
                if (checkPermission())
                    result.success(getMusicList())
                else
                    pendingResult = result
            }
            else
                result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int,
                                            permissions: Array<String>, grantResults: IntArray) {
        when (requestCode) {
            REQUEST_PERMISSION_READ_EXTERNAL_STORAGE -> {
                for (i in permissions.indices) {
                    val permission = permissions[i]
                    val grantResult = grantResults[i]
                    if (permission == Manifest.permission.READ_EXTERNAL_STORAGE) {
                        if (grantResult == PackageManager.PERMISSION_GRANTED) {
                            pendingResult?.success(getMusicList())
                            pendingResult = null
                        }
                    } else {
                        notifyNoPermissionsError()
                    }
                }
            }
            else -> {
                // do nothing
            }
        }
    }

    private fun notifyNoPermissionsError() {
        pendingResult?.error("permission", "you don't have the permission to access storage", null)
        pendingResult = null
    }

    private fun checkPermission() : Boolean {
        if (Build.VERSION.SDK_INT >= 23) {
            if (checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                        REQUEST_PERMISSION_READ_EXTERNAL_STORAGE)
                return false
            }
        }
        return true
    }

    private fun getMusicList() : ArrayList<HashMap<*, *>?>? {
        val musicFinder = MusicFinder(activity.contentResolver)

        searchMusicFiles(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC).listFiles())
        musicFinder.prepare()

        val list: ArrayList<HashMap<*, *>?> = ArrayList()
        for (s in musicFinder.allMusics)
            list.add(s.toMap())

        return list
    }

    private fun searchMusicFiles(files: Array<File>) {
        for (file in files) {
            if (file.isDirectory) {
                searchMusicFiles(file.listFiles())
            } else {
                activity.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                        Uri.parse("file://" + file.absolutePath)))
            }
        }
    }

    private fun play(url: String): Boolean? {
        if (mediaPlayer == null) {
            mediaPlayer = MediaPlayer()
            mediaPlayer!!.setAudioStreamType(AudioManager.STREAM_MUSIC)
            try {
                mediaPlayer!!.setDataSource(url)
            } catch (e: IOException) {
                e.printStackTrace()
                Log.d("AUDIO", "invalid DataSource")
            }
            mediaPlayer!!.prepareAsync()
        } else {
            channel.invokeMethod("audio.onDuration", mediaPlayer!!.duration)
            mediaPlayer!!.start()
            channel.invokeMethod("audio.onStart", true)
        }
        mediaPlayer!!.setOnPreparedListener {
            channel.invokeMethod("audio.onDuration", mediaPlayer!!.duration)
            mediaPlayer!!.start()
            channel.invokeMethod("audio.onStart", true)
        }
        mediaPlayer!!.setOnCompletionListener {
            stop()
            channel.invokeMethod("audio.onComplete", true)
        }
        mediaPlayer!!.setOnErrorListener { mp, what, extra ->
            channel.invokeMethod("audio.onError", String.format("{\"what\":%d,\"extra\":%d}", what, extra))
            true
        }
        handler.post(sendData)
        return true
    }

    private fun mute(muted: Boolean) {
        if (audioManager == null)
            return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC,
                    if (muted) AudioManager.ADJUST_MUTE else AudioManager.ADJUST_UNMUTE, 0)
        else
            audioManager.setStreamMute(AudioManager.STREAM_MUSIC, muted)
    }

    private fun seek(position: Double) {
        mediaPlayer!!.seekTo((position * 1000).toInt())
    }

    private fun stop() {
        handler.removeCallbacks(sendData)
        if (mediaPlayer != null) {
            mediaPlayer!!.stop()
            mediaPlayer!!.release()
            mediaPlayer = null
        }
    }

    private fun pause() {
        mediaPlayer!!.pause()
        handler.removeCallbacks(sendData)
    }

    private val sendData: Runnable = object : Runnable {
        override fun run() {
            try {
                if (!mediaPlayer!!.isPlaying)
                    handler.removeCallbacks(this)

                val time: Int = mediaPlayer!!.currentPosition
                channel.invokeMethod("audio.onCurrentPosition", time)
                handler.postDelayed(this, 200)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
