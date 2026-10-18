import 'package:get/get.dart';

import '../features/about/about_view.dart';
import '../features/agent/agent_controller.dart';
import '../features/agent/agent_view.dart';
import '../features/chat/chat_controller.dart';
import '../features/chat/chat_view.dart';
import '../features/documents/documents_view.dart';
import '../features/models/model_details_view.dart';
import '../features/onboarding/onboarding_view.dart';
import '../features/settings/privacy_view.dart';
import '../features/settings/reports_view.dart';
import '../features/shell/shell_view.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const shell = '/';
  static const chat = '/chat';
  static const modelDetails = '/model';
  static const privacy = '/privacy';
  static const about = '/about';
  static const agent = '/agent';
  static const documents = '/documents';
  static const reports = '/reports';
}

final appPages = [
  GetPage(name: Routes.onboarding, page: () => const OnboardingView()),
  GetPage(name: Routes.shell, page: () => const ShellView()),
  GetPage(
    name: Routes.chat,
    page: () => const ChatView(),
    binding: BindingsBuilder(() {
      Get.put(ChatController(conversationId: Get.arguments as String?));
    }),
  ),
  GetPage(name: Routes.modelDetails, page: () => const ModelDetailsView()),
  GetPage(name: Routes.privacy, page: () => const PrivacyView()),
  GetPage(name: Routes.about, page: () => const AboutView()),
  GetPage(
    name: Routes.agent,
    page: () => const AgentView(),
    binding: BindingsBuilder(() {
      Get.put(AgentController());
    }),
  ),
  GetPage(name: Routes.documents, page: () => const DocumentsView()),
  GetPage(name: Routes.reports, page: () => const ReportsView()),
];
