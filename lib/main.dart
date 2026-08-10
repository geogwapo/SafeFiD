import 'dart:async';
import 'package:flutter/material.dart';

void main() {
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
                    color: Colors.black.withOpacity(0.25),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'SafeFiD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertScreen()),
              );
            },
          ),
        ],
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

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
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

    if (selectedIndex == 3) {
      return const AlertGuideScreen();
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
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield,
                      color: Colors.green.shade700,
                      size: 35,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM STATUS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'SAFE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('All systems are normal'),
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
                child: _sensorCard('Smoke', 'Clear', Icons.cloud, Colors.green),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _sensorCard(
                  'Flame',
                  'No Fire',
                  Icons.local_fire_department,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _sensorCard(
                  'Temperature',
                  '28.6 °C',
                  Icons.thermostat,
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _sensorCard(
                  'Location',
                  'Room 3',
                  Icons.location_on,
                  Colors.blue,
                ),
              ),
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
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('VIEW LIVE CAMERA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveCameraScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // TEST ALERT BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text('TEST FIRE ALERT'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertScreen()),
                );
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

class LiveCameraScreen extends StatelessWidget {
  const LiveCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LIVE CAMERA')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CAMERA AREA
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.videocam, color: Colors.white, size: 70),
                  ),

                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '● REC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Camera: Room 3',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('10:30:15 AM'),
              ],
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sensor Readings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _reading(Icons.cloud, 'Smoke', 'Clear', Colors.green),

                _reading(
                  Icons.local_fire_department,
                  'Flame',
                  'No Fire',
                  Colors.green,
                ),

                _reading(Icons.thermostat, 'Temp.', '28.6°C', Colors.orange),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text('TAKE SNAPSHOT'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Snapshot captured!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _reading(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 35, color: color),
        const SizedBox(height: 5),
        Text(title),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ======================================================
// 4. ALERT SCREEN
// ======================================================

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveCameraScreen(),
                    ),
                  );
                },
                child: const Text('VIEW LIVE CAMERA'),
              ),
            ),

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
// 5. ALERT GUIDE
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
// 6. BFP HOTLINE POPUP
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
                onPressed: () {
                  // PHONE CALL WILL BE CONNECTED
                  // HERE LATER USING url_launcher.

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('BFP Hotline selected.')),
                  );
                },
                child: const Text('CALL BFP HOTLINE'),
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
