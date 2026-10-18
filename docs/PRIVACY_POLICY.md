# LocalMind AI — Privacy Policy (draft)

_Last updated: 2026-10-18. Draft written from the app's actual behaviour; have it reviewed before publishing._

## Summary

LocalMind AI runs AI models on your device. We do not operate servers for the app, do not require an account, and do not collect your prompts, conversations, documents or AI responses.

## Data stored on your device

- Conversations (your messages and AI responses), with timing statistics
- Downloaded or imported model files
- App settings (language, theme, generation settings, system prompt)
- Content reports you create
- Memories you save (only if you add them; used in chats only when you switch memory on)
- Documents you import and their search index

This data is kept in the app's private storage, is excluded from Android cloud backup and device-to-device transfer, and is deleted when you use **Settings → Clear all data** or uninstall the app.

## Network use

The app connects to the internet only when you choose to download a model. The file is requested from the host shown before the download (currently Hugging Face, huggingface.co). Like any web server, that host receives your IP address and standard HTTP request information, and its own privacy policy applies. The app itself never sends prompts, conversations, files or reports; the only exception is a report email that you choose to send from your own email app (see below).

The app contains no analytics, advertising or crash-reporting SDKs.

## Permissions

- **Internet** — model downloads only.
- **Network state** — to show whether you are online or offline.
- **Foreground service and notifications** — to keep a model download running in the background and show its progress. Android 13+ asks you before showing notifications.

Files are opened only when you select them with the Android file picker.

## Content reports

Reports you file about AI responses are stored on your device. If you choose "Send to developer", the app shows you the exact text and opens your own email app with a draft to us; you decide whether to send it. The draft contains only the report reason, the model name, the app version, the time and the reported AI response.

## Children

The app is not directed at children under 13.

## Contact

support@tdevs.co
