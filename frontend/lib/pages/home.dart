import 'package:flutter/material.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/pages/maps/map_page.dart';
import 'package:frontend/pages/profile/profile_page.dart';
import 'package:frontend/utils/constants/enums/bottom_bar_button_enum.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final page = ValueNotifier<BottomBarButtonEnum>(BottomBarButtonEnum.home);
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: page,
        builder: (context, value, child) {
          switch (value) {
            case BottomBarButtonEnum.home:
              return const HomePage();
            case BottomBarButtonEnum.maps:
              return const MapPage();
            case BottomBarButtonEnum.profile:
              return const ProfilePage();
          }
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: page,
        builder: (context, value, child) {
          return NavigationBar(
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home),
                label: 'Home',
                selectedIcon: const Icon(Icons.home),
              ),
              NavigationDestination(
                icon: const Icon(Icons.map),
                label: 'Maps',
                selectedIcon: const Icon(Icons.map),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person),
                label: 'Profile',
                selectedIcon: const Icon(Icons.person),
              ),
            ],
            selectedIndex: page.value.index,
            onDestinationSelected: (index) {
              page.value = BottomBarButtonEnum.values[index];
            },
          );
        },
      ),
    );
  }
}
