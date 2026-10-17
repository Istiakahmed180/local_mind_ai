import 'inference_runtime.dart';

/// Conservative token estimate when no tokenizer is available.
/// Bengali and other non-Latin scripts tokenize to more tokens per character.
int estimateTokens(String text) {
  var latin = 0;
  var other = 0;
  for (final rune in text.runes) {
    if (rune < 0x0250) {
      latin++;
    } else {
      other++;
    }
  }
  return (latin / 3.0 + other * 1.0).ceil() + 4;
}

class BudgetResult {
  const BudgetResult(this.turns, this.droppedCount);

  final List<ChatTurn> turns;
  final int droppedCount;
}

/// Keeps the system prompt and the newest turns that fit in
/// `contextSize - reservedForOutput`. Always keeps the last user turn; if even
/// that does not fit, it is truncated from the start.
BudgetResult fitToContext({
  required List<ChatTurn> turns,
  required int contextSize,
  required int reservedForOutput,
  int Function(String) countTokens = estimateTokens,
}) {
  final budget = contextSize - reservedForOutput;
  if (budget <= 0) {
    throw ArgumentError('reservedForOutput must be smaller than contextSize');
  }
  final system = turns.where((t) => t.role == ChatRole.system).toList();
  final dialog = turns.where((t) => t.role != ChatRole.system).toList();

  var used = system.fold<int>(0, (sum, t) => sum + countTokens(t.text));
  final kept = <ChatTurn>[];
  for (var i = dialog.length - 1; i >= 0; i--) {
    final cost = countTokens(dialog[i].text);
    if (used + cost > budget) {
      if (kept.isEmpty) {
        final remaining = budget - used;
        kept.add(ChatTurn(dialog[i].role, _tail(dialog[i].text, remaining)));
      }
      break;
    }
    used += cost;
    kept.add(dialog[i]);
  }
  final result = [...system, ...kept.reversed];
  return BudgetResult(result, dialog.length - kept.length);
}

String _tail(String text, int tokens) {
  if (tokens <= 0) return '';
  final runes = text.runes.toList();
  final keep = (tokens - 4).clamp(0, runes.length);
  return String.fromCharCodes(runes.sublist(runes.length - keep));
}
