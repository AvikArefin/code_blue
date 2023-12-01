import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import './setup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SetupPage(),
    );
  }
}


// Make it back groundable
// class AppRetainWidget extends StatelessWidget {
//   final Widget child;
//   const AppRetainWidget({super.key, required this.child});


//   final _channel = const MethodChannel('com.example/app_retain');

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop:  true,
//       onPopInvoked: (bool didPop) {
//         print("Tried to pop");
//       },
//       child: child,
//     );
//   }
// }

