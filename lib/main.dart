import 'dart:async';
import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minute Minder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration selectedDuration = const Duration(days: 0,hours: 1,minutes: 0,seconds: 0,milliseconds: 0,microseconds: 0);
  Duration selectedInterval = const Duration(days: 0,hours: 0,minutes: 1,seconds: 0,milliseconds: 0,microseconds: 0);
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setAsset('assets/audio/beep.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Total Duration:\n ${selectedDuration.inHours%24} Hrs ${selectedDuration.inMinutes%60} Min",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final Duration? result = await showDurationPicker(context: context, initialTime: selectedDuration);
                      setState(() {
                        selectedDuration = result!;
                      });
                    }, child: const Text("Change Duration")
                ),
              ],
            ),
            const SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Time b/w Beeps:\n ${selectedInterval.inHours%24} Hrs ${selectedInterval.inMinutes%60} Min ${selectedInterval.inSeconds%60} Sec",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final Duration? result = await showDurationPicker(context: context, initialTime: selectedInterval,baseUnit: BaseUnit.second);
                      setState(() {
                        selectedInterval = result!;
                      });
                    }, child: const Text("Change Interval")
                )
              ],
            ),
            IconButton(
              onPressed: (){
                timer = Timer.periodic(selectedInterval, (Timer t) => playBeep(_audioPlayer,timer,selectedInterval,selectedDuration));
              },
              icon: const Icon(Icons.play_circle_fill_rounded,size: 75,),
            ),
            IconButton(
              onPressed: (){
                if (timer.isActive) timer.cancel();
              },
              icon: const Icon(Icons.stop_circle_rounded,size: 75,),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

}

Future<void> playBeep(AudioPlayer audioPlayer,Timer timer, Duration selectedInterval, Duration selectedDuration) async {
  if (selectedInterval.inSeconds *timer.tick > selectedDuration.inSeconds){
    timer.cancel();
  } else {
    print(timer.tick);
    await audioPlayer.seek(Duration.zero);
    await audioPlayer.play();
  }
}