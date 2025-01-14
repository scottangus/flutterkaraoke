import 'dart:io';
import 'dart:async';

import './model_song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PlayKaraoke extends StatelessWidget {
  final TextEditingController controller = TextEditingController(text: 'START');
  final FlutterSound flutterSound = new FlutterSound();
  final ModelSong selectedSong;

  PlayKaraoke(this.selectedSong);

  final StorageReference storageReference = FirebaseStorage().ref();

  Future<String> _uploadAudio([String audioFileName]) async {
    if (audioFileName == null) {
      audioFileName = "RyoheiRecorded2.m4a";
    }
    // if (audioFile == null) {
    // audioFile = "sdcard/recorded.m4a";
    File audioFile = File("sdcard/recorded.m4a");
    // }
    StorageUploadTask ref = storageReference
        .child("audioFiles/" + audioFileName)
        .putFile(audioFile);
    String location = await (await ref.onComplete).ref.getDownloadURL();
    return location;
  }

  Future _startAudio() async {
    await flutterSound.startRecorder('sdcard/recorded.m4a');
    try {
      print(selectedSong);
      await flutterSound.startPlayer(selectedSong.downloadURL);
    } catch (e) {
      print("Error! $e");
    }
  }

  Future _stopAudio() async {
    await flutterSound.stopRecorder();
    await flutterSound.stopPlayer();
    await _uploadAudio();
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        if (controller.text == 'START') {
          _startAudio();
          controller.text = 'STOP';
        } else if (controller.text == 'STOP') {
          _stopAudio();
          controller.text = 'START';
        }
      },
      child: TextField(enabled: false, controller: controller),
    );
  }
}
