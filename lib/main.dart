import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: const Center(child: _Home()),
        ),
      );
}

class _Home extends StatefulWidget {
  const _Home({
    Key? key,
  }) : super(key: key);

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  late final Stream<KioskMode> _currentMode = watchKioskMode();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (Platform.isAndroid) ...[
            const MaterialButton(
              onPressed: startKioskMode,
              child: Text('Start Kiosk Mode'),
            ),
            const MaterialButton(
              onPressed: stopKioskMode,
              child: Text('Stop Kiosk Mode'),
            ),
          ],
          MaterialButton(
            onPressed: () => getKioskMode().then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kiosk mode: $value')),
              ),
            ),
            child: const Text('Check mode'),
          ),
          if (Platform.isIOS)
            StreamBuilder<KioskMode>(
              stream: _currentMode,
              builder: (context, snapshot) => Text(
                'Current mode: ${snapshot.data}',
              ),
            ),
          Divider(),
          OutlinedButton(
            onPressed: () {
              // The following code will enable the wakelock on the device
              // using the wakelock plugin.
              setState(() {
                Wakelock.enable();
                // You could also use Wakelock.toggle(on: true);
              });
            },
            child: const Text('enable wakelock'),
          ),
          OutlinedButton(
            onPressed: () {
              // The following code will disable the wakelock on the device
              // using the wakelock plugin.
              setState(() {
                Wakelock.disable();
                // You could also use Wakelock.toggle(on: false);
              });
            },
            child: const Text('disable wakelock'),
          ),
          const Spacer(
            flex: 2,
          ),
          FutureBuilder(
            future: Wakelock.enabled,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              final data = snapshot.data;
              // The use of FutureBuilder is necessary here to await the
              // bool value from the `enabled` getter.
              if (data == null) {
                // The Future is retrieved so fast that you will not be able
                // to see any loading indicator.
                return Container();
              }

              return Text('The wakelock is currently '
                  '${data ? 'enabled' : 'disabled'}.');
            },
          ),
        ],
      );
}
