import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:pedometer/pedometer.dart';
import 'package:geolocator/geolocator.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocationSettings locationSettings = const LocationSettings(
    distanceFilter: 2,
    accuracy: LocationAccuracy.high,
  );
  late StreamSubscription<Position> _positionStream;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '', _steps = '?';
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  late Timer timer;
  String _elapsedTime = "00:00:00";
  int getSeconds = 1;

  int getIvent = 0;
  int i = 0;
  int startSteps = 0;
  int newSteps = 0;
  double distance = 0;
  double averageSpeed = 0;
  double calorieConsumption = 0;
  double _speed = 0.0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 15), (Timer t) {
      setState(() {});
    });
    initPlatformState();
    _startStopwatch();
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) {
      // ignore: unnecessary_null_comparison
      _onSpeedChange(position == null
          ? 0.0
          : (position.speed * 18) /
              5); //Converting position speed from m/s to km/hr
    });
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

  void _onSpeedChange(double newSpeed) {
    setState(() {
      _speed = newSpeed;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    timer?.cancel();
    _positionStream.cancel();
    super.dispose();
  }

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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
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
                  height: 10,
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
                  height: 10,
                ),
                const Text(
                  'Cередня швидкість, км/год',
                  style: TextStyle(
                      fontSize: 18, color: Color.fromARGB(255, 94, 71, 64)),
                ),
                Text(
                  averageSpeed.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 40,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Активна швидкість, км/год',
                  style: TextStyle(
                      fontSize: 18, color: Color.fromARGB(255, 94, 71, 64)),
                ),
                Text(
                  _speed.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 40,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
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
                  size: 60,
                  color: const Color.fromARGB(255, 94, 71, 64),
                ),
                Center(
                  child: Text(
                    _status,
                    style: _status == 'walking' || _status == 'stopped'
                        ? const TextStyle(
                            fontSize: 30,
                            color: Color.fromARGB(255, 94, 71, 64))
                        : const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                RichText(
                    text: TextSpan(
                        text: "Витрачений час: ",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 94, 71, 64),
                            fontSize: 18),
                        children: <TextSpan>[
                      TextSpan(
                        text: _elapsedTime,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 26),
                      ),
                    ])),
                RichText(
                    text: TextSpan(
                        text: "Корисний час ",
                        style:
                            const TextStyle(color: Colors.yellow, fontSize: 18),
                        children: <TextSpan>[
                      TextSpan(
                        text: (getSeconds / 60).toStringAsFixed(0),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 26),
                      ),
                      const TextSpan(text: ' хвил.')
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
