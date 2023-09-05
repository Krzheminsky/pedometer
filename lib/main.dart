import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '', _steps = '?';
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _elapsedTime = "00:00:00";
  int getSeconds = 1;

  int getIvent = 0;
  int i = 0;
  int startSteps = 0;
  int newSteps = 0;
  double distance = 0;
  double averageSpeed = 0;
  double calorieConsumption = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _startStopwatch();
  }

  void onStepCount(StepCount event) {
    double speed = averageSpeed * 1000 / 60;
    // print(event);
    setState(() {
      getIvent = event.steps;
      _steps = event.steps.toString();
      if (i == 0) {
        startSteps += event.steps;
      }
      i += 1;
      newSteps = getIvent - startSteps;

      distance = (newSteps * 0.61 / 1000);

      averageSpeed = (distance / getSeconds) * 3600;

      calorieConsumption =
          ((((0.007 * speed * speed) + 21) * 100) * (getSeconds / 60)) / 1000;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    // print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    // print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    // print(_status);
  }

  void onStepCountError(error) {
    // print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  // ****************************************************
  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _stopwatch.elapsed.toString().substring(0, 7);

        if (_status == 'walking') {
          getSeconds += 1;
        }
      });
    });
  }
  // ****************************************************

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'М І Й   К Р О К О М І Р',
            style: TextStyle(color: Color.fromARGB(255, 217, 255, 1)),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.green[300],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Кількість кроків',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 94, 71, 64)),
              ),
              // Text(
              //   _steps,
              //   style: const TextStyle(fontSize: 60),
              // ),
              Text(
                newSteps.toString(),
                style: const TextStyle(
                    fontSize: 60,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Відстань, км',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 94, 71, 64)),
              ),
              Text(
                distance.toStringAsFixed(3),
                style: const TextStyle(
                    fontSize: 50,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Cередня швидкість, км/год',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 94, 71, 64)),
              ),
              Text(
                averageSpeed.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 50,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),

              const Text(
                'Витрачено енергії, Ккал',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 94, 71, 64)),
              ),
              Text(
                calorieConsumption.toStringAsFixed(3),
                style: const TextStyle(
                    fontSize: 40,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(
                height: 20,
              ),

              // const Text(
              //   'Статус',
              //   style: TextStyle(fontSize: 16),
              // ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 70,
                color: const Color.fromARGB(255, 94, 71, 64),
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? const TextStyle(fontSize: 30)
                      : const TextStyle(fontSize: 20, color: Colors.red),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text("Витрачений час: $_elapsedTime",
                  style:
                      const TextStyle(color: Color.fromARGB(255, 94, 71, 64))),
              Text('Корисний час ${(getSeconds / 60).toStringAsFixed(0)} хвил.',
                  style:
                      const TextStyle(color: Color.fromARGB(255, 94, 71, 64))),
            ],
          ),
        ),
      ),
    );
  }
}
