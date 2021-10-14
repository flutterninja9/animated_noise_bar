import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRecording = false;
  double _dB = 0.0;
  late final NoiseMeter _meter;
  late StreamSubscription<NoiseReading> _noiseSubscription;

  @override
  void dispose() {
    _noiseSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _meter = NoiseMeter(onError);
  }

  void onData(NoiseReading event) {
    _dB = event.meanDecibel;
    _isRecording = true;
    setState(() {});
  }

  void stop() async {
    try {
      _noiseSubscription.cancel();
      _isRecording = false;
      _dB = 0.0;
      setState(() {});
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
  }

  void start() {
    try {
      _noiseSubscription = _meter.noiseStream.listen(onData);
    } on PlatformException catch (e) {
      log("${e.message} | ${e.details}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animated NoiseBar"),
      ),
      body: Center(
        child: Text(_dB.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _isRecording ? stop() : start(),
        child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
      ),
    );
  }
}
