// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// A utility class for cleaning HTML content and converting it to plain text.
///
/// This class provides methods to strip HTML tags, convert special HTML
/// elements to their text equivalents, and normalize whitespace.
@immutable
abstract class HtmlCleaner {
  /// Private constructor to prevent instantiation of this utility class.
  const HtmlCleaner._();

  /// Cleans raw HTML content and converts it to plain text.
  ///
  /// This method performs the following operations:
  /// - Converts `<br>` tags to newlines
  /// - Removes carriage returns (`\r`)
  /// - Removes custom `<t>` tags
  /// - Strips all other HTML tags
  /// - Collapses multiple consecutive newlines to at most two
  /// - Trims leading and trailing whitespace
  ///
  /// Parameters:
  /// - [rawHtml]: The HTML content to clean
  /// - [skipCleaning]: If true, returns the input unchanged
  ///
  /// Returns the cleaned plain text.
  ///
  /// Example:
  /// ```dart
  /// final html = '<p>Hello <br> World!</p>';
  /// final cleaned = HtmlCleaner.clean(html);
  /// // Result: 'Hello \n World!'
  /// ```
  static String clean(String rawHtml, {bool skipCleaning = false}) {
    if (skipCleaning) {
      return rawHtml;
    }

    if (rawHtml.isEmpty) {
      return rawHtml;
    }

    try {
      return _performCleaning(rawHtml);
    } catch (e) {
      // If cleaning fails for any reason, return the original content
      // This ensures the widget doesn't break due to unexpected HTML formats
      return rawHtml;
    }
  }

  /// Performs the actual HTML cleaning operations.
  static String _performCleaning(String html) {
    String cleaned = html;

    // Remove script and style tags and their content
    cleaned = cleaned.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?<\/script>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?<\/style>', caseSensitive: false), '');

    // Convert break tags to newlines (case-insensitive)
    cleaned = _convertBreakTags(cleaned);

    // Remove carriage returns
    cleaned = _removeCarriageReturns(cleaned);

    // Remove custom <t> tags
    cleaned = _removeCustomTags(cleaned);

    // Strip all remaining HTML tags
    cleaned = _stripHtmlTags(cleaned);

    // Decode common HTML entities
    cleaned = _decodeHtmlEntities(cleaned);

    // Normalize whitespace
    cleaned = _normalizeWhitespace(cleaned);

    return cleaned.trim();
  }

// Add this helper to decode common HTML entities
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// Converts HTML break tags to newline characters.
  static String _convertBreakTags(String html) {
    return html.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      '\n',
    );
  }

  /// Removes carriage return characters.
  static String _removeCarriageReturns(String html) {
    return html.replaceAll('\r', '');
  }

  /// Removes custom t tags.
  static String _removeCustomTags(String html) {
    return html.replaceAll(RegExp(r'</?t>'), '');
  }

  /// Strips all HTML tags from the text.
  static String _stripHtmlTags(String html) {
    // Make tag removal case-insensitive to catch <P>, <DIV>, etc.
    return html.replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), '');
  }

  /// Normalizes whitespace by collapsing multiple newlines.
  static String _normalizeWhitespace(String text) {
    // Replace 3 or more consecutive newlines with exactly 2 newlines
    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  /// Validates if the input string contains valid HTML.
  ///
  /// This is a basic validation that checks for the presence of HTML tags.
  /// Returns true if HTML tags are detected, false otherwise.
  @visibleForTesting
  static bool containsHtml(String text) {
    return RegExp(r'<[^>]+>').hasMatch(text);
  }

  /// Counts the number of HTML tags in the input string.
  ///
  /// This method is useful for determining the complexity of HTML content.
  @visibleForTesting
  static int countHtmlTags(String html) {
    final matches = RegExp(r'<[^>]+>').allMatches(html);
    return matches.length;
  }
}
