import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/home_controller.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'core/constants/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {

  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Scaffold(
        body: screens[currentIndex],

        bottomNavigationBar:
            NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor:
              AppColors.lightPink,
          destinations: const [
            NavigationDestination(
              icon:
                  Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home,
                color: AppColors.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.person_outline),
              selectedIcon: Icon(
                Icons.person,
                color: AppColors.primary,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}