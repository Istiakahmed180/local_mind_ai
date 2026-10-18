import 'dart:math' as math;

/// A stored chunk returned by search, with what is needed to cite it.
class RetrievedPassage {
  const RetrievedPassage({
    required this.chunkId,
    required this.documentId,
    required this.documentName,
    required this.text,
    this.page,
    this.lineStart,
    this.lineEnd,
    this.score = 0,
    this.matchedTerms = const {},
  });

  final int chunkId;
  final String documentId;
  final String documentName;
  final String text;
  final int? page;
  final int? lineStart;
  final int? lineEnd;
  final double score;
  final Set<String> matchedTerms;

  RetrievedPassage withScore(double score, Set<String> matched) =>
      RetrievedPassage(
        chunkId: chunkId,
        documentId: documentId,
        documentName: documentName,
        text: text,
        page: page,
        lineStart: lineStart,
        lineEnd: lineEnd,
        score: score,
        matchedTerms: matched,
      );
}

const _stopwords = {
  // English
  'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'can', 'do', 'does',
  'did', 'for', 'from', 'has', 'have', 'how', 'i', 'in', 'is', 'it', 'its',
  'me', 'my', 'of', 'on', 'or', 'our', 'please', 'tell', 'that', 'the',
  'their', 'there', 'this', 'to', 'was', 'were', 'what', 'when', 'where',
  'which', 'who', 'whom', 'why', 'will', 'with', 'you', 'your', 'about',
  'according', 'document', 'documents', 'file', 'say', 'says',
  // Bengali
  'কি', 'কী', 'কে', 'কোন', 'কোথায়', 'কখন', 'কেন', 'কিভাবে', 'কীভাবে',
  'এবং', 'ও', 'আর', 'এই', 'সেই', 'যে', 'তা', 'হয়', 'হবে', 'ছিল', 'আমার',
  'আমাকে', 'বলুন', 'বলো', 'জন্য', 'থেকে', 'মধ্যে', 'একটি', 'এর', 'কত',
};

final _word = RegExp(r'[\p{L}\p{M}\p{N}]+', unicode: true);

/// Lower-cased content words of [query], in order, without duplicates.
/// English plurals are reduced (`refunds` → `refund`) because search matches
/// terms as prefixes.
List<String> queryTerms(String query, {int max = 12}) {
  final terms = <String>[];
  for (final m in _word.allMatches(query.toLowerCase())) {
    var t = m.group(0)!;
    if (_stopwords.contains(t)) continue;
    if (t.length < 2 && !_isNumber(t)) continue;
    t = _stem(t);
    if (!terms.contains(t)) terms.add(t);
    if (terms.length == max) break;
  }
  return terms;
}

bool _isNumber(String t) => RegExp(r'^\d+$').hasMatch(t);

String _stem(String t) {
  if (!RegExp(r'^[a-z]+$').hasMatch(t) || t.length <= 4) return t;
  if (t.endsWith('ies')) return '${t.substring(0, t.length - 3)}y';
  if (t.endsWith('ss')) return t;
  if (t.endsWith('es') && RegExp(r'(sh|ch|x|z)es$').hasMatch(t)) {
    return t.substring(0, t.length - 2);
  }
  if (t.endsWith('s')) return t.substring(0, t.length - 1);
  return t;
}

/// FTS5 MATCH expression: each term as a quoted prefix phrase, OR-ed.
/// Terms contain only letters, marks and digits, so no FTS syntax leaks in.
String ftsMatchExpression(List<String> terms) =>
    terms.map((t) => '"$t"*').join(' OR ');

/// Tokens of a passage, matched the same way as [queryTerms] (lower case).
List<String> passageTokens(String text) =>
    _word.allMatches(text.toLowerCase()).map((m) => m.group(0)!).toList();

/// Ranks candidates with BM25 (k1 1.2, b 0.75), counting a token as a hit when
/// it starts with a query term, then multiplies by the share of distinct query
/// terms the passage contains so passages covering more of the question win.
///
/// [totalChunks] is the size of the whole index; document frequencies come from
/// the candidate set, which contains every chunk that matches any term when the
/// candidate limit is not hit.
List<RetrievedPassage> rankPassages(
  List<RetrievedPassage> candidates,
  List<String> terms, {
  required int totalChunks,
  int limit = 5,
}) {
  if (terms.isEmpty || candidates.isEmpty) return const [];
  final tokenized = [for (final c in candidates) passageTokens(c.text)];
  final avgLen =
      tokenized.fold<int>(0, (n, t) => n + t.length) / tokenized.length;
  final n = math.max(totalChunks, candidates.length);

  final df = <String, int>{};
  final tf = <Map<String, int>>[];
  for (final tokens in tokenized) {
    final counts = <String, int>{};
    for (final token in tokens) {
      for (final term in terms) {
        if (token.startsWith(term)) counts[term] = (counts[term] ?? 0) + 1;
      }
    }
    for (final term in counts.keys) {
      df[term] = (df[term] ?? 0) + 1;
    }
    tf.add(counts);
  }

  const k1 = 1.2, b = 0.75;
  final ranked = <RetrievedPassage>[];
  for (var i = 0; i < candidates.length; i++) {
    final counts = tf[i];
    if (counts.isEmpty) continue;
    final len = tokenized[i].length;
    var score = 0.0;
    for (final entry in counts.entries) {
      final d = df[entry.key]!;
      final idf = math.log(1 + (n - d + 0.5) / (d + 0.5));
      final f = entry.value;
      score += idf * f * (k1 + 1) / (f + k1 * (1 - b + b * len / avgLen));
    }
    score *= 0.5 + counts.length / terms.length;
    ranked.add(candidates[i].withScore(score, counts.keys.toSet()));
  }
  ranked.sort((x, y) {
    final c = y.score.compareTo(x.score);
    return c != 0 ? c : x.chunkId.compareTo(y.chunkId);
  });
  return ranked.take(limit).toList();
}

/// True when the passages together contain at least half of the query terms
/// (and at least one). Below that the app answers "not enough evidence"
/// without asking the model.
bool hasEnoughEvidence(List<RetrievedPassage> passages, List<String> terms) {
  if (terms.isEmpty || passages.isEmpty) return false;
  final covered = passages.expand((p) => p.matchedTerms).toSet();
  return covered.length >= math.max(1, (terms.length / 2).ceil());
}
