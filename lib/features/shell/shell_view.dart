import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
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
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.of(context).hairline),
            ),
          ),
          child: NavigationBar(
            selectedIndex: c.index.value,
            onDestinationSelected: (i) => c.index.value = i,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: 'nav_home'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.forum_outlined),
                selectedIcon: const Icon(Icons.forum_rounded),
                label: 'nav_chats'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.memory_outlined),
                selectedIcon: const Icon(Icons.memory_rounded),
                label: 'nav_models'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: 'nav_settings'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
