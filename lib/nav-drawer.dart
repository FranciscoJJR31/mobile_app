import 'package:flutter/material.dart';
import 'package:mobile_app/informacionPage.dart';
import 'package:mobile_app/main.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:isolate';
import 'package:postgres/postgres.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'dart:math' show cos, sqrt, asin;

import 'MapPage.dart';

bool sendalert = false;

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  String? _event = "Agresor Cerca!";

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'AVISO',
      notificationText: '$_event',
    );
    WidgetsFlutterBinding.ensureInitialized();
    if (sendalert == true) {
      sendPort?.send(_event);
      // Send data to the main isolate.
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();

  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const NavDrawer(),
        '/resume-route': (context) => MapPage(),
      },
    );
  }
}

class _NavDrawerState extends State<NavDrawer> {
  ReceivePort? _receivePort;

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    //await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'AVISO',
        notificationText: 'Aplicacion monitoreada',
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((message) {
      if (message is int) {
        print('eventCount: $message');
      } else if (message is String) {
        if (message == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (message is DateTime) {
        print('timestamp: ${message.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    SearchDatos();
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        child: Text(text),
        onPressed: onPressed,
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'SOA Menú',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Pagina de inicio'),
            onTap: () => {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => informacionPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Mapa'),
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MapPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Desloguearse'),
            onTap: () => {
              _stopForegroundTask(),
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              )
            },
          ),
        ],
      ),
    );
  }

  void SearchDatos() async {
    var Array, id_victima, id_agresor, id_orden, radio;
    var PosVictima, PosAgresor;
    double Latvictima;
    double Latagresor;
    double lonvictima;
    double lonagresor;
    double radius = 0;

    var connection = PostgreSQLConnection("worker.local.com", 5432, "appdb",
        username: "appuser", password: "strongpasswordapp", useSSL: false);
    String? id_app_flutter = await PlatformDeviceId.getDeviceId;
    Location location = new Location();
    LocationData _locationData;
    _locationData = await location.getLocation();

    await connection.open();

    Array = await connection.query(
        "SELECT * FROM orden INNER JOIN ubicacion_victima ON orden.id_victima=ubicacion_victima.id_victima where ubicacion_victima.id_app_movil='$id_app_flutter' LIMIT 1");

    id_orden = Array[0][0];
    id_victima = Array[0][1].toString();
    id_agresor = Array[0][2].toString();
    radio = Array[0][3];
    PosVictima = await connection.query(
        "select * from ubicacion_victima where id_victima = '$id_victima' order by id_ubicacion_victima DESC LIMIT 1");
    PosAgresor = await connection.query(
        "select * from ubicacion_agresor where id_agresor = '$id_agresor' order by id_ubicacion_agresor DESC LIMIT 1");

    radius = double.parse(radio.toString());
    Latvictima = double.parse(PosVictima[0][4].toString());
    Latagresor = double.parse(PosAgresor[0][3].toString());
    lonvictima = double.parse(PosVictima[0][3].toString());
    lonagresor = double.parse(PosAgresor[0][2].toString());

    await connection.close();
    //await Future.delayed(Duration(seconds: 2));
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * 1000 * asin(sqrt(a));
    }

    if (calculateDistance(Latvictima, lonvictima, Latagresor, lonagresor) -
            double.parse(radio.toString()) >
        10) {
      _stopForegroundTask();
      sendalert = false;
    } else {
      _initForegroundTask();
      sendalert = true;
      _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
        // You can get the previous ReceivePort without restarting the service.
        if (await FlutterForegroundTask.isRunningService) {
          final newReceivePort = FlutterForegroundTask.receivePort;
          _registerReceivePort(newReceivePort);
        }
      });
      _stopForegroundTask();
      _startForegroundTask();

      //NotificationService().initNotification();
      // NotificationService()
      //     .showNotification(title: 'ALERTA!', body: 'Agresor cerca!');
    }
  }
}
