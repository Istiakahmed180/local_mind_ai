import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/recommendation.dart';

void main() {
  const gb = 1024 * 1024 * 1024;
  final catalog = ModelCatalog.fromJson(
    jsonDecode(File('assets/models/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  ).chatModels;

  test('smallest suitable model comes first', () {
    final r = recommendModels(
      catalog: catalog,
      totalRamBytes: 8 * gb,
      freeStorageBytes: 50 * gb,
    );
    expect(r.first.fit, Fit.recommended);
    final recommended = r.where((f) => f.fit == Fit.recommended).toList();
    for (var i = 1; i < recommended.length; i++) {
      expect(
        recommended[i].model.sizeBytes,
        greaterThanOrEqualTo(recommended[i - 1].model.sizeBytes),
      );
    }
  });

  test('a 2 GB device does not get the 1.7B model recommended', () {
    final r = recommendModels(
      catalog: catalog,
      totalRamBytes: 2 * gb,
      freeStorageBytes: 50 * gb,
    );
    final big = r.firstWhere((f) => f.model.id == 'qwen3-1.7b-q8_0');
    expect(big.fit, Fit.tooLarge);
  });

  test('not enough storage marks a model too large', () {
    final r = recommendModels(
      catalog: catalog,
      totalRamBytes: 16 * gb,
      freeStorageBytes: 100 * 1024 * 1024,
    );
    expect(r.every((f) => f.fit == Fit.tooLarge), isTrue);
  });

  test('unknown RAM is reported as unknown, not guessed', () {
    final r = recommendModels(
      catalog: catalog,
      totalRamBytes: null,
      freeStorageBytes: null,
    );
    expect(r.every((f) => f.fit == Fit.unknown), isTrue);
  });

  test(
    'Bengali preference ranks Bengali-capable models first within a fit group',
    () {
      final r = recommendModels(
        catalog: catalog,
        totalRamBytes: 8 * gb,
        freeStorageBytes: 50 * gb,
        preferBengali: true,
      );
      expect(r.first.model.bengali, BengaliSupport.vendorClaimed);
    },
  );
}
