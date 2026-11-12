import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

final AudioPlayer audioPlayer = AudioPlayer();

bool alertSoundEnabled = true;
bool notificationsEnabled = true;
bool fireDetectedGlobal = false;

double? smokeLevel;
double? flameLevel;
StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? sensorSubscription;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SafeFiDApp());
}

class SafeFiDApp extends StatelessWidget {
  const SafeFiDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeFiD',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const SplashScreen(),
    );
  }
}

// ======================================================
// 1. SPLASH SCREEN
// ======================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDashboard()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A38),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.red,
                size: 75,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'SafeFiD',
              style: TextStyle(
                color: Colors.red,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Smart Detection.\nFast Alert.\nSafer Lives.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
            ),

            const SizedBox(height: 45),

            const SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                color: Colors.red,
                backgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// 2. HOME DASHBOARD
// ======================================================

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    sensorSubscription = FirebaseFirestore.instance
        .collection('sensor_readings')
        .doc('0AuxMVjVKQlGcpaIBnVP')
        .snapshots()
        .listen(
          (snapshot) async {
            if (!snapshot.exists) return;

            final data = snapshot.data();
            if (data == null) return;

            final smoke = data['smoke'];
            final flame = data['flame'];

            if (smoke is! num || flame is! num) return;

            final newSmoke = smoke.toDouble();
            final newFlame = flame.toDouble();

            final alarmTriggered = newSmoke > 30 || newFlame < 600;

            final wasAlarmTriggered = fireDetectedGlobal;

            if (!mounted) return;

            setState(() {
              smokeLevel = newSmoke;
              flameLevel = newFlame;
              fireDetectedGlobal = alarmTriggered;
            });

            if (alarmTriggered && !wasAlarmTriggered) {
              await FirebaseFirestore.instance.collection('fire_alerts').add({
                'status': newSmoke > 30 && newFlame < 600
                    ? 'SMOKE AND FLAME ALERT'
                    : newSmoke > 30
                    ? 'SMOKE ALERT'
                    : 'FLAME ALERT',
                'location': 'Room 3, Second Floor',
                'smoke': newSmoke,
                'flame': newFlame,
                'timestamp': FieldValue.serverTimestamp(),
              });

              if (alertSoundEnabled) {
                await audioPlayer.play(AssetSource('siren.mp3'));
              }
            }

            if (!alarmTriggered && wasAlarmTriggered) {
              await audioPlayer.stop();
            }
          },
          onError: (Object error) {
            debugPrint('Sensor stream error: $error');
          },
        );
  }

  @override
  void dispose() {
    sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'SafeFiD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _buildBody(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: fireDetectedGlobal
                ? const Icon(Icons.notifications_active, color: Colors.red)
                : const Icon(Icons.notifications_none),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Guide'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (selectedIndex == 1) {
      return const AlertScreen();
    }

    if (selectedIndex == 2) {
      return const HistoryScreen();
    }

    if (selectedIndex == 3) {
      return const AlertGuideScreen();
    }

    if (selectedIndex == 4) {
      return const SettingsScreen();
    }

    return _dashboard();
  }

  Widget _dashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SYSTEM STATUS
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fireDetectedGlobal
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield,
                      color: fireDetectedGlobal
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      size: 35,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM STATUS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        fireDetectedGlobal ? 'FIRE DETECTED!' : 'SAFE',
                        style: TextStyle(
                          color: fireDetectedGlobal ? Colors.red : Colors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        fireDetectedGlobal
                            ? 'Emergency alert detected!'
                            : 'All systems are normal',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // SENSOR READINGS
          Row(
            children: [
              Expanded(
                child: _sensorCard(
                  'Smoke Level',
                  smokeLevel == null ? '--' : smokeLevel!.toStringAsFixed(1),
                  Icons.cloud,
                  smokeLevel != null && smokeLevel! > 30
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sensorCard(
                  'Flame Level',
                  flameLevel == null ? '--' : flameLevel!.toStringAsFixed(0),
                  Icons.local_fire_department,
                  flameLevel != null && flameLevel! < 600
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _sensorCard(
                  'Location',
                  'Room 3',
                  Icons.location_on,
                  Colors.blue,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 20),

          // MONITORING INFORMATION
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monitoring Time'),
                      Text(
                        '02:45:10',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last Update'),
                      Text(
                        '10:30 AM',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LIVE CAMERA BUTTON
          const SizedBox(height: 12),

          // TEST ALERT BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text('TEST FIRE ALERT'),
              onPressed: () async {
                setState(() {
                  fireDetectedGlobal = true;
                });

                await FirebaseFirestore.instance.collection('fire_alerts').add({
                  'status': 'TEST FIRE DETECTED',
                  'location': 'Room 3, Second Floor',
                  'smoke': 'HIGH',
                  'flame': 'DETECTED',
                  'temperature': 86.4,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                if (alertSoundEnabled) {
                  await audioPlayer.play(AssetSource('siren.mp3'));
                }

                if (!mounted) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertScreen()),
                );

                if (!mounted) return;

                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),

            const SizedBox(height: 8),

            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 5),

            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// 3. LIVE CAMERA & SENSOR SCREEN
// ======================================================

// ======================================================
// 4. ALERT SCREEN
// ======================================================

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!fireDetectedGlobal) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: const Text('ALERTS'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'NO ACTIVE ALERTS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('All systems are currently normal.'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text('FIRE ALERT'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ALERT HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 60,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'FIRE DETECTED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _alertInfo('Location', 'Room 3, Second Floor'),

            _alertInfo('Time Detected', 'Today, 10:30 AM'),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Smoke'),
                      Text(
                        'HIGH',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Flame'),
                      Text(
                        'DETECTED',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Temperature'),
                      Text(
                        '86.4 °C',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlertGuideScreen(),
                    ),
                  );
                },
                child: const Text('VIEW GUIDE'),
              ),
            ),

            const SizedBox(height: 20),
            // RETURN TO SAFE MODE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check_circle),
                label: const Text('RETURN TO SAFE MODE'),
                onPressed: () {
                  fireDetectedGlobal = false;
                  audioPlayer.stop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeDashboard(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // BFP HOTLINE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.phone),
                label: const Text('CALL BFP HOTLINE'),
                onPressed: () {
                  showBfpDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _alertInfo(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
// ======================================================
// 5. HISTORY SCREEN
// ======================================================

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORY'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fire_alerts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load alert history.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No fire alerts recorded yet.'));
          }

          final alerts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final data = alerts[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['status'] ?? 'UNKNOWN ALERT',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${data['location'] ?? 'Unknown location'}\n'
                    'Smoke: ${data['smoke'] ?? 'Unknown'}\n'
                    'Flame: ${data['flame'] ?? 'Unknown'}\n'
                    'Time: ${_formatTimestamp(data['timestamp'])}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null) {
    return 'Time unavailable';
  }

  if (timestamp is Timestamp) {
    final date = timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  return 'Time unavailable';
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.red),
              title: const Text('Notifications'),
              subtitle: const Text('Receive fire alert notifications'),
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.volume_up, color: Colors.red),
              title: const Text('Alert Sound'),
              subtitle: const Text('Play siren when fire is detected'),
              trailing: Switch(
                value: alertSoundEnabled,
                onChanged: (value) {
                  setState(() {
                    alertSoundEnabled = value;
                  });
                },
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Monitored Location'),
              subtitle: const Text('Room 3, Second Floor'),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.red),
              title: const Text('About SafeFiD'),
              subtitle: const Text('Smart Detection. Fast Alert. Safer Lives.'),
            ),
          ),
        ],
      ),
    );
  }
}
// ======================================================
// 6. ALERT GUIDE
// ======================================================

class AlertGuideScreen extends StatelessWidget {
  const AlertGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ['Stay Calm', "Don't panic. Check the situation.", Icons.person],
      [
        'Evacuate',
        'Go to the nearest exit and help others.',
        Icons.directions_run,
      ],
      ['Report', 'Use the app to call for help if needed.', Icons.phone],
      [
        'Go to Assembly Point',
        'Proceed to the designated safe area.',
        Icons.groups,
      ],
      ['Do Not Go Back Inside', 'Wait for the response team.', Icons.block],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('WHAT TO DO')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                step[0] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(step[1] as String),
              trailing: Icon(step[2] as IconData, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
// ======================================================
// 7. BFP HOTLINE POPUP
// ======================================================

void showBfpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.red,
              child: Icon(Icons.phone, color: Colors.white, size: 35),
            ),

            const SizedBox(height: 15),

            const Text(
              'CALL BFP HOTLINE?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Do you want to call the\n'
              'BFP Hotline now?',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: '0822910441');

                  try {
                    final bool launched = await launchUrl(
                      phoneUri,
                      mode: LaunchMode.externalApplication,
                    );

                    if (!launched) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to open the phone dialer.'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open the phone dialer.'),
                      ),
                    );
                  }
                },
                child: const Text('CALL NOW'),
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('CANCEL'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
