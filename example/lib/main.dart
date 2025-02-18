import 'dart:math';

import 'package:command/command.dart';
import 'package:example/counter_command.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  final _counterCommand = CounterCommand(0);
  final _randomNumberCommand = Command.crerate(
    value: 0,
    action: (_) async {
      return Random().nextInt(100);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: _counterCommand,
              builder: (context, i, child) {
                return Text(
                  'Counte Command as ValueListenable (ChangeNotify) = ${_counterCommand.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            ListenableBuilder(
              listenable: _counterCommand,
              builder: (context, child) {
                return Text(
                  'Counte Command as Listenable (ChangeNotify) = ${_counterCommand.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            ElevatedButton(
              onPressed: _counterCommand.execute,
              child: const Text("Incrrement"),
            ),
            const SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _randomNumberCommand,
              builder: (context, snapshot) {
                return Text(
                  'Random number Command as Stream = ${snapshot.data}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            ElevatedButton(
              onPressed: _randomNumberCommand.execute,
              child: const Text("Random number"),
            ),
          ],
        ),
      ),
    );
  }
}
