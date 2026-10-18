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
import 'data/repositories/memory_repository.dart';
import 'data/repositories/document_repository.dart';
import 'data/repositories/model_repository.dart';
import 'services/device/device_info_service.dart';
import 'services/documents/document_service.dart';
import 'services/documents/embedding_service.dart';
import 'services/documents/ocr_service.dart';
import 'services/inference/embedding_runtime.dart';
import 'services/inference/llamadart_runtime.dart';
import 'services/inference/model_runtime_service.dart';
import 'services/model_service.dart';
import 'services/chat_transfer.dart';
import 'services/settings_service.dart';
import 'services/voice/voice_service.dart';

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
  Get.put(MemoryRepository(db), permanent: true);
  Get.put(ChatTransferService(db), permanent: true);
  Get.put(VoiceService(settings), permanent: true);
  final docRepo = DocumentRepository(db);
  final documents = Get.put(DocumentService(docRepo), permanent: true);
  final models = await Get.putAsync(
    () => ModelService(modelRepo, device).init(),
    permanent: true,
  );
  documents.ocr = await Get.putAsync<OcrService>(
    () => OcrService(freeBytes: device.freeStorageBytes).init(),
    permanent: true,
  );
  final chatRuntime = Get.put(
    ModelRuntimeService(LlamadartRuntime(), models, modelRepo, settings),
    permanent: true,
  );
  // Explicit type: inferring from the nullable field would register the
  // service as `EmbeddingService?`, which Get.find<EmbeddingService>() misses.
  documents.semantic = Get.put<EmbeddingService>(
    EmbeddingService(
      docRepo,
      models,
      settings,
      chatRuntime,
      LlamadartEmbeddingRuntime(),
    ),
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
    yield const LicenseEntryWithLineBreaks([
      'Tesseract OCR 5.5.1',
      'Tesseract4Android 4.9.0',
      'tessdata_fast',
    ], _apacheOcr);
    yield const LicenseEntryWithLineBreaks(['Leptonica 1.85.0'], _leptonica);
    yield const LicenseEntryWithLineBreaks(['libjpeg v9f'], _libjpeg);
    yield const LicenseEntryWithLineBreaks(['libpng 1.6.48'], _libpng);
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

const _apacheOcr = '''Licensed under the Apache License, Version 2.0 (the "License"); you may not use these files except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Tesseract OCR: Copyright the Tesseract contributors (originally Hewlett-Packard and Google).
Tesseract4Android: Copyright Robert Pösel and contributors (fork of tess-two by Robert Theis).
tessdata_fast language data: Copyright the Tesseract contributors.''';

const _leptonica = '''Copyright (C) 2001-2024 Leptonica. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANY CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.''';

const _libjpeg =
    '''This software is based in part on the work of the Independent JPEG Group.

libjpeg is copyright (C) 1991-2024, Thomas G. Lane, Guido Vollbeding. It is distributed under the IJG license.''';

const _libpng = '''libpng: Copyright (c) 1995-2025 The PNG Reference Library Authors. Copyright (c) 2018-2025 Cosmin Truta. Copyright (c) 1998-2018 Glenn Randers-Pehrson. Copyright (c) 1996-1997 Andreas Dilger. Copyright (c) 1995-1996 Guy Eric Schalnat, Group 42, Inc.

The software is supplied "as is", without warranty of any kind, express or implied. Distributed under the PNG Reference Library License version 2: permission is granted to use, copy, modify and distribute this software, provided the copyright notices are not removed or altered and altered versions are plainly marked as such.''';
