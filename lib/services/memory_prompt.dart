import '../data/local/database.dart';

/// Upper bound on memory text added to the system prompt, so memories never
/// crowd out the conversation on small context windows.
const maxMemoryPromptChars = 1500;

/// Builds the system-prompt block for saved memories, newest omitted first
/// when over budget. Returns null when there is nothing to add.
({String text, int used, int omitted})? buildMemoryBlock(
  List<MemoryEntry> entries, {
  int maxChars = maxMemoryPromptChars,
}) {
  final enabled = entries.where((e) => e.enabled).toList();
  if (enabled.isEmpty) return null;
  final lines = <String>[];
  var length = 0;
  for (final e in enabled) {
    final line = '- ${e.content}';
    if (length + line.length + 1 > maxChars) break;
    lines.add(line);
    length += line.length + 1;
  }
  if (lines.isEmpty) return null;
  final text =
      '\n\nThe user asked you to remember these facts about them. '
      'Use them only when relevant and do not repeat them unprompted:\n'
      '${lines.join('\n')}';
  return (
    text: text,
    used: lines.length,
    omitted: enabled.length - lines.length,
  );
}
