import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/finance_models.dart';

class FinanceProvider extends ChangeNotifier {
  final List<FinanceEntry> _entries = [];
  bool _loading = false;
  String? _error;
  Map<String, double>? _overrideMonthlyTotals; // if set, takes precedence

  List<FinanceEntry> get entries => List.unmodifiable(_entries);
  bool get loading => _loading;
  String? get error => _error;

  Map<String, double> get monthlyTotals => _overrideMonthlyTotals ?? const <String, double>{};

  // Removed generic CSV row parsing; focusing only on CW totals.

  

  // Accept either a spreadsheet ID, a Google Sheets share URL, or a published CSV (2PACX) link and fetch.
  Future<void> fetchFromPublicSpreadsheetInput(String input, {DateTime? startMonth, List<String>? sheetNames}) async {
    final trimmed = input.trim();
    // If it's a published-to-web CSV link, fetch directly as CSV.
    if (trimmed.contains('/spreadsheets/d/e/2PACX') && trimmed.contains('output=csv')) {
      await _fetchPublishedCsvCwTotals(trimmed, startMonth: startMonth, sheetNames: sheetNames);
      return;
    }
    // Otherwise, treat as Share link or raw ID and fetch month-wise sheets.
    final id = _extractSpreadsheetId(trimmed);
    if (id == null) {
      _error = 'Invalid spreadsheet link. Provide a Google Sheets Share link (Anyone with the link can view) or the raw spreadsheet ID.';
      notifyListeners();
      return;
    }
  await fetchFromSpreadsheet(id, startMonth: startMonth, sheetNames: sheetNames);
  }

  Future<void> _fetchPublishedCsvCwTotals(String basePublishedCsvUrl, {DateTime? startMonth, List<String>? sheetNames}) async {
    _loading = true;
    _error = null;
    _entries.clear();
    _overrideMonthlyTotals = {};
    notifyListeners();
    try {
  final start = DateTime((startMonth ?? DateTime(2025, 1)).year, (startMonth ?? DateTime(2025, 1)).month);
  final end = _endMonthToShow(DateTime.now());
  final months = end != null ? _monthsBetween(start, end) : <DateTime>[];
  final baseUri = Uri.parse(basePublishedCsvUrl);
      // Try to discover sheet name -> gid mapping from published HTML
      final gidMap = await _discoverPublishedSheetGids(baseUri);
  final targetSheets = sheetNames ?? [ for (final m in months) '${_monthFullUpper(m.month)} ${m.year}' ];
      for (final base in targetSheets) {
        final candidates = _titleCandidatesStandardFromBase(base);
        String? gid;
        for (final c in candidates) {
          gid = gidMap[c.toLowerCase()];
          if (gid != null) break;
        }
        final qp = Map<String, String>.from(baseUri.queryParameters);
        qp['single'] = 'true';
        qp['output'] = 'csv';
        Uri? url;
        if (gid != null) {
          qp['gid'] = gid;
          qp.remove('sheet');
          url = baseUri.replace(queryParameters: qp);
        } else {
          // fallback to sheet name (first base only)
          qp.remove('gid');
          qp['sheet'] = base;
          url = baseUri.replace(queryParameters: qp);
        }
        try {
          final res = await http.get(url);
          if (res.statusCode == 200) {
            final value = _extractLastRowCwValue(res.body);
            if (value != null) {
              final dt = _parseSheetTitleToMonthYear(base);
              final key = dt != null ? yearMonthKey(dt) : base;
              _overrideMonthlyTotals![key] = value;
            }
          }
        } catch (_) {}
      }
      // Fill any missing months with 0 so all months from 2025 are visible
      for (final m in months) {
        final key = yearMonthKey(m);
        _overrideMonthlyTotals!.putIfAbsent(key, () => 0.0);
      }
      if (_overrideMonthlyTotals!.isEmpty) {
        _error = 'No monthly totals found. Ensure the published link includes all sheets (publish "Entire document") or provide the normal Share link/ID.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFromSpreadsheet(String spreadsheetId, {DateTime? startMonth, List<String>? sheetNames}) async {
    _loading = true;
    _error = null;
    _overrideMonthlyTotals = {};
    notifyListeners();
    try {
  final start = DateTime((startMonth ?? DateTime(2025, 1)).year, (startMonth ?? DateTime(2025, 1)).month);
  final end = _endMonthToShow(DateTime.now());
  final months = end != null ? _monthsBetween(start, end) : <DateTime>[];
  _entries.clear();
      // Discover exact sheet titles and gids so we fetch by gid only (prevents wrong defaults)
  final titleToGid = await _discoverShareSheetGids(spreadsheetId);
  final seenBodies = <String>{};
      final targetSheets = sheetNames ?? [
        for (final m in months) '${_monthFullUpper(m.month)} ${m.year}'
      ];
      for (final sheetName in targetSheets) {
          final candidates = _sheetNameVariants(sheetName).map((s) => s.toLowerCase()).toList();
          String? gid;
          for (final c in candidates) {
            gid = titleToGid[c];
            if (gid != null) break;
          }
          if (gid != null) {
            try {
              final url = Uri.parse('https://docs.google.com/spreadsheets/d/$spreadsheetId/export?format=csv&gid=$gid');
              final res = await http.get(url);
              if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
                final v = _extractLastRowCwValue(res.body);
                if (v != null) {
                  final dt = _parseSheetTitleToMonthYear(sheetName);
                  final key = dt != null ? yearMonthKey(dt) : sheetName;
                  _overrideMonthlyTotals![key] = v;
                  continue; // next sheet
                }
              }
            } catch (_) {
              // fall through to name-based
            }
          }
          // Fallback: try by sheet name variants via gviz CSV
          double? found;
          for (final candidate in candidates) {
            final url = Uri.parse('https://docs.google.com/spreadsheets/d/$spreadsheetId/gviz/tq?tqx=out:csv&sheet=${Uri.encodeComponent(candidate)}');
            try {
              final res = await http.get(url);
              if (res.statusCode == 200) {
                final body = res.body.trim();
                if (body.isEmpty) continue;
                final sig = '${body.length}:${body.hashCode}';
                if (seenBodies.contains(sig)) {
                  // Likely default/duplicate sheet; skip this candidate
                  continue;
                }
                final v = _extractLastRowCwValue(body);
                if (v != null) {
                  seenBodies.add(sig);
                  found = v; break;
                }
              }
            } catch (_) { /* try next variant */ }
          }
          if (found != null) {
            final dt = _parseSheetTitleToMonthYear(sheetName);
            final key = dt != null ? yearMonthKey(dt) : sheetName;
            _overrideMonthlyTotals![key] = found;
          }
      }
      // Fill any missing months with 0 so all months from 2025 are visible
      for (final m in months) {
        final key = yearMonthKey(m);
        _overrideMonthlyTotals!.putIfAbsent(key, () => 0.0);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, String>> _discoverShareSheetGids(String spreadsheetId) async {
    final map = <String, String>{};
    try {
      // Fetch the edit HTML, which contains embedded JSON with sheetId and title
      final url = Uri.parse('https://docs.google.com/spreadsheets/d/$spreadsheetId/edit');
      final res = await http.get(url);
      if (res.statusCode != 200 || res.body.isEmpty) return map;
      final html = res.body;
      // Try multiple regex patterns to be resilient to markup changes
      final patterns = <RegExp>[
        // Direct JSON occurrences
        RegExp(r'"sheetId"\s*:\s*(\d+)\s*,\s*"title"\s*:\s*"([^"]+)"', caseSensitive: false),
        // Escaped within script strings
        RegExp(r'\\"sheetId\\"\s*:\s*(\d+)\s*,\s*\\"title\\"\s*:\s*\\"([^\\"]+)\\"', caseSensitive: false),
      ];
      for (final re in patterns) {
        for (final m in re.allMatches(html)) {
          final gid = m.group(1);
          final rawTitle = m.group(2);
          if (gid == null || rawTitle == null) continue;
          final title = rawTitle.replaceAll('\u00A0', ' ');
          final rawKey = title.toLowerCase();
          final trimmedKey = title.trim().toLowerCase();
          if (rawKey.isNotEmpty) map[rawKey] = gid;
          if (trimmedKey.isNotEmpty) map[trimmedKey] = gid;
        }
      }
    } catch (_) {}
    return map;
  }

  Future<Map<String, String>> _discoverPublishedSheetGids(Uri basePublishedCsvUri) async {
    // Try two variants: output=html and /pubhtml
    Future<String?> fetchHtml(Uri uri) async {
      try {
        final res = await http.get(uri);
        if (res.statusCode == 200 && res.body.isNotEmpty) return res.body;
      } catch (_) {}
      return null;
    }

    // Variant 1: replace output=csv with output=html
    final qp1 = Map<String, String>.from(basePublishedCsvUri.queryParameters);
    qp1['output'] = 'html';
    final htmlUrl1 = basePublishedCsvUri.replace(queryParameters: qp1);
    String? html = await fetchHtml(htmlUrl1);

    // Variant 2: /pubhtml path
    if (html == null) {
      final htmlUrl2 = basePublishedCsvUri.replace(path: basePublishedCsvUri.path.replaceFirst('/pub', '/pubhtml'));
      html = await fetchHtml(htmlUrl2);
    }

  final map = <String, String>{};
    if (html == null) return map;

    // Parse anchor tags with gid and visible text as sheet name
    final anchorRe = RegExp(r'<a[^>]*href="([^"]*?gid=(\d+)[^"]*)"[^>]*>([^<]+)</a>', caseSensitive: false);
    for (final match in anchorRe.allMatches(html)) {
      final gid = match.group(2);
      final rawTitle = match.group(3);
      final title = rawTitle?.replaceAll('\u00A0', ' ');
      if (gid != null && title != null && title.trim().isNotEmpty) {
        map[title.toLowerCase()] = gid;
        map[title.trim().toLowerCase()] = gid;
      }
    }
    return map;
  }

  double? _extractLastRowCwValue(String csvBody) {
    final rows = const LineSplitter().convert(csvBody).map(_splitCsvLine).toList();
    if (rows.isEmpty) return null;
    bool isRowEmpty(List<String> r) => r.every((c) => c.trim().isEmpty);
    final cwIndex = _columnLabelToIndex('CW');
    if (cwIndex < 0) return null;

    // 1) Prefer a "total"-labelled row near the bottom
    final totalRe = RegExp(r'\b(total|grand total|net total)\b', caseSensitive: false);
    int scanned = 0;
    for (int idx = rows.length - 1; idx >= 0 && scanned < 50; idx--, scanned++) {
      final row = rows[idx];
      if (isRowEmpty(row)) continue;
      final hasTotalLabel = row.any((c) => totalRe.hasMatch(c));
      if (hasTotalLabel && cwIndex < row.length) {
        final v = _tryParseAmount(row[cwIndex].trim());
        if (v != null) return v;
      }
    }

    // 2) Otherwise, take the first numeric in CW scanning upwards
    scanned = 0;
    for (int idx = rows.length - 1; idx >= 0 && scanned < 50; idx--, scanned++) {
      final row = rows[idx];
      if (isRowEmpty(row)) continue;
      if (cwIndex < row.length) {
        final v = _tryParseAmount(row[cwIndex].trim());
        if (v != null) return v;
      }
    }
    return null;
  }
  
    List<String> _sheetNameVariants(String base) => _titleCandidatesStandardFromBase(base);

    List<String> _titleCandidatesStandardFromBase(String base) {
      // Only allow MONTH YEAR with optional leading/trailing spaces
      final trimmed = base.trim();
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length != 2) return [trimmed, ' $trimmed', '$trimmed ', ' $trimmed '];
      final month = parts[0].toUpperCase();
      final year = parts[1];
      final mNum = _monthFromName(month);
      if (mNum == null) return [trimmed, ' $trimmed', '$trimmed ', ' $trimmed '];
      final canonical = '${_monthFullUpper(mNum)} $year';
      return [
        canonical,
        ' $canonical',
        '$canonical ',
        ' $canonical ',
      ];
    }

  int _columnLabelToIndex(String label) {
    // Convert column label (e.g., A, Z, AA, CW) to zero-based index
    int idx = 0;
    for (int i = 0; i < label.length; i++) {
      final code = label.codeUnitAt(i);
      final upper = (code >= 97 && code <= 122) ? code - 32 : code; // to upper
      if (upper < 65 || upper > 90) continue;
      idx = idx * 26 + (upper - 65 + 1);
    }
    return idx - 1; // zero-based
  }

  // Try to parse a spreadsheet ID from common "Share" links or raw ID.
  String? _extractSpreadsheetId(String input) {
    final trimmed = input.trim();
    // Raw ID
    final rawId = RegExp(r'^[a-zA-Z0-9_-]{20,}$');
    if (!trimmed.startsWith('http') && rawId.hasMatch(trimmed) && !trimmed.startsWith('2PACX-')) {
      return trimmed;
    }
    // Share URL: https://docs.google.com/spreadsheets/d/<ID>/...
    final match = RegExp(r'https?://docs\.google\.com/spreadsheets/d/([a-zA-Z0-9_-]{20,})').firstMatch(trimmed);
    if (match != null) {
      return match.group(1);
    }
  // Note: published-to-web URLs using /d/e/2PACX are handled directly as CSV in fetchFromPublicSpreadsheetInput.
    return null;
  }

  List<DateTime> _monthsBetween(DateTime start, DateTime end) {
    final out = <DateTime>[];
    var y = start.year;
    var m = start.month;
    while (y < end.year || (y == end.year && m <= end.month)) {
      out.add(DateTime(y, m));
      m++;
      if (m > 12) { m = 1; y++; }
    }
    return out;
  }

  // Apply rules:
  // - Always exclude current month
  // - Include last month only when today's date > 9; else include up to (now - 2 months)
  DateTime? _endMonthToShow(DateTime now) {
    final y = now.year;
    final m = now.month;
    // Determine offset: 1 month back if day > 9; otherwise 2 months back
    final back = (now.day > 9) ? 1 : 2;
    int em = m - back;
    int ey = y;
    while (em <= 0) { em += 12; ey -= 1; }
    if (DateTime(ey, em).isBefore(DateTime(2025, 1))) {
      // If computed end is before start of 2025, nothing to show
      return null;
    }
    return DateTime(ey, em);
  }

  String _monthAbbrUpper(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[(month - 1).clamp(0, 11)];
  }

  String _monthFullUpper(int month) {
    const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    return months[(month - 1).clamp(0, 11)];
  }

  DateTime? _parseSheetTitleToMonthYear(String title) {
    final parts = title.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) return null;
    final m = _monthFromName(parts[0]);
    final y = int.tryParse(parts[1]);
    if (m == null || y == null) return null;
    return DateTime(y, m);
  }

  // Removed row-wise CSV parsing logic; focusing only on CW totals.

  // Removed header index helpers for row parsing.

  DateTime? _tryParseDate(String input) {
    var s = input.trim();
    if (s.isEmpty) return null;
    // Normalize commas like "Aug 1, 2025"
    s = s.replaceAll(',', '');
    // Try ISO first
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // Try separators
    final sep = s.contains('/') ? '/' : (s.contains('-') ? '-' : null);
    if (sep != null) {
      final parts = s.split(sep).where((p) => p.isNotEmpty).toList();
      if (parts.length == 3) {
        // Month names like 10 Aug 2025 or Aug 10 2025
        final monthFromName = _monthFromName(parts[1]);
        if (monthFromName != null) {
          final d = int.tryParse(parts[0]);
          final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
          if (d != null && y != null) {
            return DateTime(y, monthFromName, d);
          }
        }
        // Numeric dd/MM/yyyy or MM/dd/yyyy or yyyy/MM/dd
        final a = int.tryParse(parts[0]);
        final b = int.tryParse(parts[1]);
        final c = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (a != null && b != null && c != null) {
          // If first is year
          if (a >= 1900 && a <= 2100) {
            return DateTime(a, b, c);
          }
          // If first can't be month but second can be month => dd/MM/yyyy
          if (a > 12 && b >= 1 && b <= 12) {
            return DateTime(c, b, a);
          }
          // Else assume MM/dd/yyyy
          return DateTime(c, a, b);
        }
      }
    }
    // Try formats like Aug 10 2025
    final tokens = s.split(RegExp(r'\s+'));
    if (tokens.length == 3) {
      final m = _monthFromName(tokens[0]);
      final d = int.tryParse(tokens[1]);
      final y = int.tryParse(tokens[2].length == 2 ? '20${tokens[2]}' : tokens[2]);
      if (m != null && d != null && y != null) return DateTime(y, m, d);
    }
    return null;
  }

  int? _monthFromName(String s) {
    final t = s.trim().toLowerCase();
    const names = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'sept': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    return names[t];
  }

  double? _tryParseAmount(String input) {
    var s = input.trim();
    if (s.isEmpty) return null;
    // Handle parentheses for negative amounts
    bool negative = false;
    final paren = RegExp(r'^\((.*)\)$');
    final m = paren.firstMatch(s);
    if (m != null) {
      negative = true;
      s = m.group(1) ?? s;
    }
    // Strip currency symbols and group separators
    s = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    // If there are multiple dashes, keep only the leading one
    s = s.replaceAll(RegExp(r'(.+)-'), r'$1');
    final val = double.tryParse(s);
    if (val == null) return null;
    return negative ? -val : val;
  }

  // Basic CSV splitter handling quoted fields with commas
  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        // Toggle quotes or escape
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }
}
