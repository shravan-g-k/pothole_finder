import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/pages/maps/map_page/map_page.dart';
import 'package:frontend/pages/profile/profile_page.dart';
import 'package:frontend/utils/constants/enums/bottom_bar_button_enum.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final page = ValueNotifier<BottomBarButtonEnum>(BottomBarButtonEnum.maps);
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
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(100),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 0),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        margin: const EdgeInsets.all(16),
        child: BlocBuilder<MapsBloc, MapsState>(
          builder: (context, state) {
            if (state is RouteNavigationStarted) {
              return const SizedBox.shrink();
            }
            return ValueListenableBuilder(
              valueListenable: page,
              builder: (context, value, child) {
                return NavigationBar(
                  backgroundColor: Colors.transparent,
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
            );
          },
        ),
      ),
    );
  }
}
