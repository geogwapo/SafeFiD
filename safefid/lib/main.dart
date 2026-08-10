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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SafeFiD"), centerTitle: true),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 90, color: Colors.green),

            const SizedBox(height: 20),

            const Text(
              "SMART SMOKE AND FIRE\nDETECTION SYSTEM",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            const Text("FIRE STATUS", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                "🟢 SAFE",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("EMERGENCY SOS"),
            ),
          ],
        ),
      ),
    );
  }
}
