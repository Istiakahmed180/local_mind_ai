import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../history/history_view.dart';
import '../home/home_view.dart';
import '../models/model_library_view.dart';
import '../settings/settings_view.dart';

class ShellController extends GetxController {
  final index = 0.obs;
}

class ShellView extends StatelessWidget {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ShellController());
    const tabs = [
      HomeView(),
      HistoryView(),
      ModelLibraryView(),
      SettingsView(),
    ];
    return Obx(
      () => Scaffold(
        body: IndexedStack(index: c.index.value, children: tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: c.index.value,
          onDestinationSelected: (i) => c.index.value = i,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.space_dashboard_outlined),
              selectedIcon: const Icon(Icons.space_dashboard),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.forum_outlined),
              selectedIcon: const Icon(Icons.forum),
              label: 'nav_chats'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.memory_outlined),
              selectedIcon: const Icon(Icons.memory),
              label: 'nav_models'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: 'nav_settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
