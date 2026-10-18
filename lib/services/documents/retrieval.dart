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
    this.similarity,
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

  /// Cosine similarity to the question when found by meaning search.
  final double? similarity;

  RetrievedPassage withSimilarity(double? similarity) => RetrievedPassage(
    chunkId: chunkId,
    documentId: documentId,
    documentName: documentName,
    text: text,
    page: page,
    lineStart: lineStart,
    lineEnd: lineEnd,
    score: score,
    matchedTerms: matchedTerms,
    similarity: similarity,
  );

  RetrievedPassage withText(String text) => RetrievedPassage(
    chunkId: chunkId,
    documentId: documentId,
    documentName: documentName,
    text: text,
    page: page,
    lineStart: lineStart,
    lineEnd: lineEnd,
    score: score,
    matchedTerms: matchedTerms,
    similarity: similarity,
  );

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
        similarity: similarity,
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
  // Question and helper words that rarely appear in the answer text.
  'many', 'much', 'long', 'often', 'would', 'could', 'should', 'may',
  'might', 'must', 'am', 'been', 'being', 'if', 'any', 'we', 'they',
  'need', 'want', 'know',
  // Bengali
  'কি', 'কী', 'কে', 'কোন', 'কোথায়', 'কখন', 'কেন', 'কিভাবে', 'কীভাবে',
  'এবং', 'ও', 'আর', 'এই', 'সেই', 'যে', 'তা', 'হয়', 'হবে', 'ছিল', 'আমার',
  'আমাকে', 'বলুন', 'বলো', 'জন্য', 'থেকে', 'মধ্যে', 'একটি', 'এর', 'কত',
  'কয়', 'কয়টি', 'কিসের', 'যায়', 'আছে', 'পারি', 'পারে', 'করতে', 'হলে',
};

final _word = RegExp(r'[\p{L}\p{M}\p{N}]+', unicode: true);

/// Lower-cased, stemmed content words of [query], in order, without
/// duplicates. Search matches a passage token when its stem starts with a
/// term, so `return` finds `returned` and `day` finds `days`.
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

final _latin = RegExp(r'^[a-z]+$');

String _stem(String t) =>
    _latin.hasMatch(t) ? _stemEnglish(t) : _stemBengali(t);

/// Light English suffix stripping (plurals, -ed, -ing, final e). Stems only
/// need to be prefixes of the other forms, since matching is by prefix.
String _stemEnglish(String t) {
  if (t.length <= 3) return t;
  if (t.length > 4 && (t.endsWith('ies') || t.endsWith('ied'))) {
    return '${t.substring(0, t.length - 3)}y';
  }
  if (t.endsWith('sses')) {
    t = t.substring(0, t.length - 2);
  } else if (RegExp(r'(sh|ch|x|z)es$').hasMatch(t)) {
    t = t.substring(0, t.length - 2);
  } else if (t.endsWith('s') &&
      !t.endsWith('ss') &&
      !t.endsWith('us') &&
      !t.endsWith('is')) {
    t = t.substring(0, t.length - 1);
  } else if (t.endsWith('ed') && !t.endsWith('eed') && t.length >= 5) {
    t = _undouble(t.substring(0, t.length - 2));
  } else if (t.endsWith('ing') && t.length >= 6) {
    t = _undouble(t.substring(0, t.length - 3));
  }
  if (t.length > 3 && t.endsWith('e') && !t.endsWith('ee')) {
    t = t.substring(0, t.length - 1);
  }
  return t;
}

String _undouble(String t) {
  final n = t.length;
  if (n >= 4 && t[n - 1] == t[n - 2] && !'aeioulsz'.contains(t[n - 1])) {
    return t.substring(0, n - 1);
  }
  return t;
}

/// Common Bengali case and plural endings, longest first. A word keeps at
/// least two letters so short words are left alone.
const _bengaliSuffixes = [
  'গুলোর', 'গুলির', 'গুলো', 'গুলি', 'দের', 'টির', 'টার',
  'ের', 'টি', 'টা', 'কে', 'তে', 'ার', 'ির',
];

String _stemBengali(String t) {
  for (final s in _bengaliSuffixes) {
    if (t.endsWith(s) && t.length - s.length >= 2) {
      final base = t.substring(0, t.length - s.length);
      // -ার/-ির: keep the vowel sign, drop only the case ending র.
      return s == 'ার' || s == 'ির' ? '$base${s[0]}' : base;
    }
  }
  return t;
}

/// The prefix the database searches for [term]: a stem ending in `y` may
/// appear as `ies`/`ied` (battery → batteries), so that `y` is left off.
String searchPrefix(String term) =>
    term.length > 4 && term.endsWith('y') && _latin.hasMatch(term)
    ? term.substring(0, term.length - 1)
    : term;

/// FTS5 MATCH expression: each term's [searchPrefix] as a quoted prefix
/// phrase, OR-ed. Terms contain only letters, marks and digits, so no FTS
/// syntax leaks in.
String ftsMatchExpression(List<String> terms) =>
    terms.map((t) => '"${searchPrefix(t)}"*').join(' OR ');

/// Stemmed tokens of a passage, matched the same way as [queryTerms]: a token
/// matches a term when it starts with it.
List<String> passageTokens(String text) => _word
    .allMatches(text.toLowerCase())
    .map((m) => _stem(m.group(0)!))
    .toList();

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
///
/// With [minSimilarity], a passage whose meaning-search similarity reaches it
/// also counts as evidence, so questions phrased with different words than
/// the document can still be answered.
bool hasEnoughEvidence(
  List<RetrievedPassage> passages,
  List<String> terms, {
  double? minSimilarity,
}) {
  if (passages.isEmpty) return false;
  if (minSimilarity != null &&
      passages.any((p) => (p.similarity ?? -1) >= minSimilarity)) {
    return true;
  }
  if (terms.isEmpty) return false;
  final covered = passages.expand((p) => p.matchedTerms).toSet();
  return covered.length >= math.max(1, (terms.length / 2).ceil());
}
