import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

void main() {
  runApp(const ListenAudio());
}


class ListenAudio extends StatelessWidget {
  const ListenAudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const Listenerhomepage()
    );
  }
}

class Listenerhomepage extends StatefulWidget {
  const Listenerhomepage ({super.key});
  @override

  State<Listenerhomepage> createState() => _ListenerhomepageState();
}

class _ListenerhomepageState extends State<Listenerhomepage> {
  FilePickerResult? result;

  AudioPlayer audioPlayer = AudioPlayer();
  double playRate=1;

  Duration _progress = const Duration();
  Duration _buffered = Duration();
  Duration _total = const Duration();

  bool _isPlaying = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    updateProgressBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audio Listener'
        ),
        //backgroundColor: Colors.blueAccent,
        backgroundColor: Theme.of(
          context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(
              'https://static.vecteezy.com/system/resources/previews/023/986/631/original/whatsapp-logo-whatsapp-logo-transparent-whatsapp-icon-transparent-free-free-png.png',
              height: 300,
            ),
            result == null
              ? const Text('scegli un vocale')
              : Text(result!.files.single.name),
            Column(
              children: [
                SizedBox(width: 300, height: 30, child: progressBarCreater()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: playAudio,
                  icon: const Icon(Icons.play_arrow),
                  ),
                IconButton(
                  onPressed: pauseAudio,
                  icon: const Icon(Icons.pause),
                  ),
                IconButton(
                  onPressed: stopAudio,
                  icon: const Icon(Icons.stop),
                  ),
                ElevatedButton(
                  onPressed: playbackRate,
                  child: Text('x$playRate')),
              ],
            ),
            /*
            Column(
              children: [
                const Icon(Icons.volume_up),
                SizedBox(width: 300, height: 30, child: volumeBarCreater()),
              ],
            ),
            */
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickfile,
        child: const Icon(Icons.audio_file)),
    );
  }

  
  Widget volumeBarCreater() {
    return Slider(value: 100, onChanged: sliderChanged, );
  }

  void sliderChanged(double value){}
  

  Widget progressBarCreater(){
    return ProgressBar(
      progress: _progress,
      buffered: _buffered,
      total: _total,
      onSeek: (p) {
        audioPlayer.seek(p);
      },
      progressBarColor: Colors.lightBlue,
      baseBarColor: Colors.white.withOpacity(0.24),
      bufferedBarColor: Colors.white.withOpacity(0.24),
      thumbColor: Colors.white,
      barHeight: 3.0,
      thumbRadius: 5.0,
      timeLabelLocation: TimeLabelLocation.sides,
    );
  }

  void updateProgressBar(){
    audioPlayer.onPlayerStateChanged.throttleTime(const Duration(milliseconds: 100)).listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (_isPlaying) {
          startTimer();
        } else {
          stopTimer();
        }
      });
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
    final Duration? position = await audioPlayer.getCurrentPosition();
    setState(() {
      _progress = position ?? Duration.zero;
    });
  });
  }

  void stopTimer() {
    timer.cancel();
  }

  void playAudio() {
    if(result!=null){
      audioPlayer.play(DeviceFileSource(result!.files.single.path!));
      audioPlayer.onDurationChanged.listen((Duration d) {
        setState(() {
          _total = d;
        });
      });
    }
  }

  void pauseAudio(){
    if(result!=null){
      audioPlayer.pause();
    }
  }

  void stopAudio(){
    if(result!=null){
      audioPlayer.stop();
      setState(() {
        _progress = Duration(milliseconds: 0);
      });
    }
  }

  void playbackRate() {
    switch(playRate){
      case 1:
        playRate = 1.5;
        break;

      case 1.5:
        playRate = 2;
        break;

      case 2:
        playRate = 1;
        break;
    }
    audioPlayer.setPlaybackRate(playRate);
    setState(() {});
  }

  void throwAlert() {
    QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    text: 'Wrong File Extension!',
    );
  }
  
  void pickfile() async{
    result = await FilePicker.platform.pickFiles(
      initialDirectory: "Memoria/Android/media/com.whatsapp/WhatsApp/Media/Whatsapp Voice Notes"
    );
    if(!(result!.files.single.name.endsWith('.opus'))){
      throwAlert();
      result = null;
    }

    setState(() {});
  }
}

