// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:squeeze_pix/controllers/history_screen.dart';
// import 'package:squeeze_pix/pages/pixel_lab_screen.dart';
// import 'package:squeeze_pix/theme/app_theme.dart';

// // TODO: Make sure to import your main compression screen.
// // For example: import 'package:squeeze_pix/screens/compressor_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   static const List<Widget> _widgetOptions = <Widget>[
//     Placeholder(), // Your main screen for picking/compressing images
//     PixelLabScreen(),
//     HistoryScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(gradient: AppTheme.gradient),
//         child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.compress),
//             label: 'Compress',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.grid_view_rounded),
//             label: 'Pixel Lab',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         // This is the crucial fix for the labels
//         type: BottomNavigationBarType.fixed,
//         // Optional: Add some styling to make it look better
//         backgroundColor:Colors.red,
//         selectedItemColor: Theme.of(context).colorScheme.primary,
//         unselectedItemColor: Colors.grey,
//         elevation: 10,
//       ),
//     );
//   }
// }
