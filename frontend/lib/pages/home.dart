import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/pages/maps/map_page/map_bottom_bar/map_bottom_bar.dart';
import 'package:frontend/pages/maps/map_page/map_page.dart';
import 'package:frontend/pages/profile/profile_page.dart';
import 'package:frontend/utils/constants/enums/bottom_bar_button_enum.dart';
import 'package:frontend/utils/constants/ui/box_decor_const.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final page = ValueNotifier<BottomBarButtonEnum>(BottomBarButtonEnum.maps);
    final theme = Theme.of(context);
    MediaQuery.of(context);
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
      floatingActionButton: BlocBuilder<MapsBloc, MapsState>(
        builder: (context, state) {
          if (state is RouteLoadNextSegment) {
            return MapBottomBar(
              distance: state.distance,
              duration: state.duration,
              endAddress: state.endAddress,
            );
          } else {
            return Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(BoxDecorConst.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ValueListenableBuilder(
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
              ),
            );
          }
        },
      ),
    );
  }
}
