import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_config.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'app/translations.dart';
import 'data/local/database.dart';
import 'data/repositories/conversation_repository.dart';
import 'data/repositories/document_repository.dart';
import 'data/repositories/model_repository.dart';
import 'services/device/device_info_service.dart';
import 'services/documents/document_service.dart';
import 'services/inference/llamadart_runtime.dart';
import 'services/inference/model_runtime_service.dart';
import 'services/model_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerNativeLicenses();

  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  final settings = Get.put(SettingsService(prefs), permanent: true);
  final device = Get.put(DeviceInfoService(), permanent: true);
  final modelRepo = Get.put(ModelRepository(db), permanent: true);
  Get.put(db, permanent: true);
  Get.put(ConversationRepository(db), permanent: true);
  Get.put(DocumentService(DocumentRepository(db)), permanent: true);
  final models = await Get.putAsync(
    () => ModelService(modelRepo, device).init(),
    permanent: true,
  );
  Get.put(
    ModelRuntimeService(LlamadartRuntime(), models, modelRepo, settings),
    permanent: true,
  );

  runApp(LocalMindApp(settings: settings));
}

class LocalMindApp extends StatelessWidget {
  const LocalMindApp({super.key, required this.settings});

  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode.value,
      translations: AppTranslations(),
      locale: settings.locale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: settings.onboarded.value ? Routes.shell : Routes.onboarding,
      getPages: appPages,
    );
  }
}

void _registerNativeLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['llama.cpp / ggml'], _mitLlamaCpp);
    yield const LicenseEntryWithLineBreaks(['PDFium'], _bsdPdfium);
  });
}

const _mitLlamaCpp = '''MIT License

Copyright (c) 2023-2026 The ggml authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''';

const _bsdPdfium = '''Copyright 2014 The PDFium Authors

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

   * Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following disclaimer
in the documentation and/or other materials provided with the
distribution.
   * Neither the name of Google Inc. nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.''';
