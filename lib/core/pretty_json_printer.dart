import 'dart:convert';

import 'package:flutter/material.dart';

/// Pretty prints a JSON response with proper formatting and line breaks.
///
/// This function takes a Map or other JSON-serializable object, converts it to
/// a formatted JSON string, and prints it line by line in the debug console
/// with a custom header and footer.
///
/// @param data The JSON data to be formatted and printed
/// @param title Optional title to be displayed in the header/footer (default: "JSON RESPONSE")
void prettyPrintJson(dynamic data, {String title = "JSON RESPONSE"}) {
  try {
    // Convert the data to a prettified JSON string
    final String prettyJson = const JsonEncoder.withIndent('  ').convert(data);

    // Split the string into lines
    final List<String> lines = prettyJson.split('\n');

    // Print header
    debugPrint('===== $title START =====');

    // Print each line separately to avoid truncation
    for (String line in lines) {
      debugPrint(line);
    }

    // Print footer
    debugPrint('===== $title END =====');
  } catch (e) {
    // In case of any error during JSON encoding
    debugPrint('===== ERROR PRINTING JSON =====');
    debugPrint('Error: $e');
    debugPrint('Original data: $data');
    debugPrint('===== ERROR PRINTING JSON END =====');
  }
}
