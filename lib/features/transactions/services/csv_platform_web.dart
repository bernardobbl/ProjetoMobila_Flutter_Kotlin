// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> saveCsvAndShare(String content, String fileName) async {
  // Encode explicitly as UTF-8 bytes so the Blob content matches the BOM
  // written at the start of the CSV string and accented chars are preserved.
  final blob = html.Blob([utf8.encode(content)], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final ua = html.window.navigator.userAgent.toLowerCase();
  // iPadOS 13+ reports a macOS desktop UA — check platform too.
  final isIOS = ua.contains('iphone') ||
      ua.contains('ipad') ||
      ua.contains('ipod') ||
      (ua.contains('macintosh') && (html.window.navigator.maxTouchPoints ?? 0) > 1);

  if (isIOS) {
    // iOS Safari ignores the `download` attribute and navigates to the blob
    // instead of saving it. Opening in a new tab lets the user long-press →
    // "Save to Files" or use the native Share sheet.
    html.window.open(url, '_blank');
    Timer(const Duration(seconds: 2), () => html.Url.revokeObjectUrl(url));
    return;
  }

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  // Delay revocation so the browser has time to start fetching the blob
  // before the URL is invalidated (Firefox and Safari are sensitive to this).
  Timer(const Duration(seconds: 2), () => html.Url.revokeObjectUrl(url));
}
