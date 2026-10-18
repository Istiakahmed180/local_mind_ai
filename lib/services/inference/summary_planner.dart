import 'context_budget.dart';
import 'inference_runtime.dart';

/// Room kept in the prompt for the running summary.
const summaryReserveTokens = 256;

/// Longest summary the model may write.
const summaryMaxTokens = 220;

/// A single message longer than this is shortened before summarizing, so one
/// huge message cannot block progress.
const summaryMessageChars = 1500;

/// Which older messages to fold into the summary before replying.
class SummaryPlan {
  const SummaryPlan(this.toSummarize, this.newCoveredCount);

  final List<ChatTurn> toSummarize;

  /// How many messages from the start the summary will cover afterwards.
  final int newCoveredCount;
}

/// Returns null when every message not yet covered by the summary fits
/// next to the system prompt, the summary and the new user message.
///
/// [history] is the chat's usable messages, oldest first, excluding the new
/// user message. The first [coveredCount] are already in the summary.
SummaryPlan? planSummary({
  required String systemText,
  required String? summary,
  required List<ChatTurn> history,
  required int coveredCount,
  required String newUserText,
  required int contextSize,
  required int reservedForOutput,
  int Function(String) countTokens = estimateTokens,
}) {
  final budget = contextSize - reservedForOutput;
  final summaryCost = summary == null
      ? summaryReserveTokens
      : countTokens(summary).clamp(summaryReserveTokens, budget);
  var used = countTokens(systemText) + countTokens(newUserText) + summaryCost;
  final uncovered = history.sublist(coveredCount.clamp(0, history.length));
  var keep = 0;
  for (var i = uncovered.length - 1; i >= 0; i--) {
    final cost = countTokens(uncovered[i].text);
    if (used + cost > budget) break;
    used += cost;
    keep++;
  }
  final drop = uncovered.length - keep;
  if (drop <= 0) return null;
  return SummaryPlan(
    uncovered.sublist(0, drop),
    coveredCount.clamp(0, history.length) + drop,
  );
}

String _shorten(String s) => s.length <= summaryMessageChars
    ? s
    : '${s.substring(0, summaryMessageChars)} …';

String _line(ChatTurn t) =>
    '${t.role == ChatRole.user ? 'User' : 'Assistant'}: ${_shorten(t.text.trim())}';

/// Splits [messages] into chunks whose text fits [budgetTokens], keeping
/// order. Every chunk has at least one message.
List<List<ChatTurn>> chunkForSummary(
  List<ChatTurn> messages,
  int budgetTokens, {
  int Function(String) countTokens = estimateTokens,
}) {
  final chunks = <List<ChatTurn>>[];
  var current = <ChatTurn>[];
  var used = 0;
  for (final m in messages) {
    final cost = countTokens(_line(m));
    if (current.isNotEmpty && used + cost > budgetTokens) {
      chunks.add(current);
      current = [];
      used = 0;
    }
    current.add(m);
    used += cost;
  }
  if (current.isNotEmpty) chunks.add(current);
  return chunks;
}

/// Prompt that folds [messages] into [previousSummary].
List<ChatTurn> buildSummaryPrompt(
  String? previousSummary,
  List<ChatTurn> messages,
) => [
  const ChatTurn(
    ChatRole.system,
    'You summarize conversations so they can be continued later. Keep '
    'names, numbers, dates, decisions, the user\'s stated preferences and '
    'any open questions. Do not add anything that was not said. Write in the '
    'same language as the conversation. At most 120 words, plain sentences, '
    'no headings.',
  ),
  ChatTurn(
    ChatRole.user,
    '${previousSummary == null ? '' : 'Summary so far:\n$previousSummary\n\n'}'
    'New messages:\n${messages.map(_line).join('\n')}\n\n'
    'Write the updated summary of the whole conversation.',
  ),
];

/// Text added to the system prompt when a summary exists.
String summaryBlock(String summary) =>
    '\n\nSummary of the earlier part of this conversation (written by the '
    'assistant, may be incomplete):\n$summary';

/// Token budget for the message text in one summarizing request.
int summaryInputBudget(int contextSize, String? previousSummary) {
  final overhead =
      estimateTokens(
        buildSummaryPrompt(previousSummary, const []).map((t) => t.text).join(),
      ) +
      summaryMaxTokens;
  return (contextSize - overhead).clamp(64, contextSize);
}
