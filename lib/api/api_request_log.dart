import 'dart:convert';

import 'package:flutter/foundation.dart';

/// HTTP 接口调试日志：统一格式输出请求 URL、Query 与原始响应体，便于对照抓包/后端文档。
///
/// - 默认仅在 [kDebugMode] 下输出；发布环境可保持 `enabled = false`。
/// - 超长响应按 [maxBodyChars] 截断，避免控制台卡顿。
class ApiRequestLog {
  ApiRequestLog._();

  /// 为 `false` 时不输出任何日志（例如正式包强制关闭）。
  static bool enabled = kDebugMode;

  /// 单条响应体最多输出字符数（美化后的字符串长度）。
  static int maxBodyChars = 80000;

  static void _line(String s) {
    if (!enabled) return;
    debugPrint(s);
  }

  /// 发起请求时调用（当前客户端仅使用 GET）。
  static void request(String method, Uri uri) {
    if (!enabled) return;
    final b = StringBuffer()
      ..writeln('┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
      ..writeln('┃ [API 请求] $method')
      ..writeln('┃ path: ${uri.path}')
      ..writeln('┃ full: $uri');
    if (uri.hasQuery && uri.queryParameters.isNotEmpty) {
      b.writeln('┃ query:');
      for (final e in uri.queryParameters.entries) {
        b.writeln('┃   ${e.key} = ${e.value}');
      }
    }
    b.write('┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _line(b.toString());
  }

  /// HTTP 层响应（含非 200，便于看错误页 HTML/JSON）。
  static void httpResponse(
    Uri uri,
    int statusCode,
    String rawBody, {
    Duration? duration,
  }) {
    if (!enabled) return;
    final ms = duration != null ? ' ${duration.inMilliseconds} ms' : '';
    final pretty = _tryPrettyJson(rawBody);
    final body = _truncate(pretty);
    final b = StringBuffer()
      ..writeln('┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
      ..writeln('┃ [API 响应] HTTP $statusCode$ms')
      ..writeln('┃ path: ${uri.path}')
      ..writeln('┃ body (${utf8.encode(rawBody).length} bytes raw):');
    _line(b.toString());
    for (final line in body.split('\n')) {
      _line('┃   $line');
    }
  }

  /// 业务层 envelope：`code != 1` 时在已打印 body 之外再强调一行摘要。
  static void apiEnvelope(Uri uri, int code, String msg) {
    if (!enabled) return;
    _line('┃ [API 业务] code=$code msg=${msg.isEmpty ? '(empty)' : msg}  path=${uri.path}');
    _line('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// 一次请求成功结束（`code == 1`）时闭合分隔线。
  static void successFooter(Uri uri) {
    if (!enabled) return;
    _line('┃ [API 完成] path=${uri.path}');
    _line('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// HTTP 非 200 等，在已打印 body 后收尾。
  static void httpFailureFooter(Uri uri, int statusCode) {
    if (!enabled) return;
    _line('┃ [API 结束] HTTP $statusCode path=${uri.path}');
    _line('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void jsonDecodeError(Uri uri, Object error, StackTrace stack) {
    if (!enabled) return;
    _line('┃ [API 解析失败] path=${uri.path}  error=$error');
    _line('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrintStack(stackTrace: stack, label: 'ApiRequestLog');
  }

  static void unexpectedError(Uri uri, Object error, StackTrace stack) {
    if (!enabled) return;
    _line('┃ [API 异常] path=${uri.path}  error=$error');
    _line('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrintStack(stackTrace: stack, label: 'ApiRequestLog');
  }

  static void wrongJsonRoot(Uri uri, String detail) {
    if (!enabled) return;
    _line('┃ [API 数据形状] path=${uri.path}  $detail');
    _line('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static String _tryPrettyJson(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '(empty body)';
    try {
      final dynamic v = json.decode(raw);
      const enc = JsonEncoder.withIndent('  ');
      return enc.convert(v);
    } catch (_) {
      return raw;
    }
  }

  static String _truncate(String s) {
    if (s.length <= maxBodyChars) return s;
    return '${s.substring(0, maxBodyChars)}\n…(truncated, ${s.length} chars total)';
  }
}
