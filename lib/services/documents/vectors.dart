import 'dart:math' as math;
import 'dart:typed_data';

import 'retrieval.dart';

/// Little-endian float32 bytes, as stored in `chunk_embeddings.vector`.
Uint8List encodeVector(List<double> v) {
  final data = ByteData(v.length * 4);
  for (var i = 0; i < v.length; i++) {
    data.setFloat32(i * 4, v[i], Endian.little);
  }
  return data.buffer.asUint8List();
}

Float32List decodeVector(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final out = Float32List(bytes.length ~/ 4);
  for (var i = 0; i < out.length; i++) {
    out[i] = data.getFloat32(i * 4, Endian.little);
  }
  return out;
}

/// Returns [v] scaled to unit length (or unchanged if it is all zeros).
List<double> normalize(List<double> v) {
  var sum = 0.0;
  for (final x in v) {
    sum += x * x;
  }
  if (sum == 0) return v;
  final n = math.sqrt(sum);
  return [for (final x in v) x / n];
}

/// Cosine similarity of two unit vectors; 0 when the lengths differ.
double dot(List<double> a, List<double> b) {
  if (a.length != b.length) return 0;
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

/// The [k] stored vectors most similar to [query], best first.
List<(int chunkId, double similarity)> topSimilar(
  List<double> query,
  List<(int chunkId, Float32List vector)> stored,
  int k,
) {
  final scored = [for (final (id, v) in stored) (id, dot(query, v))]
    ..sort((a, b) {
      final c = b.$2.compareTo(a.$2);
      return c != 0 ? c : a.$1.compareTo(b.$1);
    });
  return scored.take(k).toList();
}

/// Reciprocal Rank Fusion of keyword and semantic rankings. A passage found
/// by both rises to the top; one found by either is still kept. Keyword
/// passages keep their matched terms, semantic ones their similarity.
List<RetrievedPassage> fuseRankings(
  List<RetrievedPassage> keyword,
  List<RetrievedPassage> semantic, {
  int limit = 5,
  int k = 60,
}) {
  final byId = <int, RetrievedPassage>{};
  final score = <int, double>{};
  for (var i = 0; i < keyword.length; i++) {
    final p = keyword[i];
    byId[p.chunkId] = p;
    score[p.chunkId] = (score[p.chunkId] ?? 0) + 1 / (k + i + 1);
  }
  for (var i = 0; i < semantic.length; i++) {
    final p = semantic[i];
    final existing = byId[p.chunkId];
    byId[p.chunkId] = existing == null
        ? p
        : existing.withSimilarity(p.similarity);
    score[p.chunkId] = (score[p.chunkId] ?? 0) + 1 / (k + i + 1);
  }
  final ids = score.keys.toList()
    ..sort((a, b) {
      final c = score[b]!.compareTo(score[a]!);
      return c != 0 ? c : a.compareTo(b);
    });
  return [for (final id in ids.take(limit)) byId[id]!];
}
