// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'constants.dart';

/// A utility class for measuring text and calculating appropriate truncation
/// points for the "see more" functionality.
///
/// This class provides methods to determine if text needs to be truncated
/// and calculates the optimal truncation point to fit within specified
/// constraints while leaving room for the "see more" label.
@immutable
abstract class TextMeasure {
  /// Private constructor to prevent instantiation of this utility class.
  const TextMeasure._();

  /// Computes a truncated version of text that fits within the given constraints
  /// while leaving space for a "see more" label.
  ///
  /// This method uses binary search to find the optimal truncation point that
  /// allows the text plus the "see more" label to fit within the specified
  /// number of lines and width.
  ///
  /// Parameters:
  /// - [text]: The text to potentially truncate
  /// - [style]: The text style to use for measurement
  /// - [maxWidth]: The maximum width constraint
  /// - [maxLines]: The maximum number of lines allowed
  /// - [seeMoreLabel]: The "see more" text that will be appended
  /// - [textDirection]: The text direction for layout
  /// - [textAlign]: The text alignment for layout
  ///
  /// Returns the truncated text if truncation is needed, or null if the
  /// original text fits within the constraints.
  ///
  /// Example:
  /// ```dart
  /// final truncated = TextMeasure.computeCollapsedTextForSeeMore(
  ///   text: 'This is a very long text...',
  ///   style: TextStyle(fontSize: 16),
  ///   maxWidth: 300,
  ///   maxLines: 2,
  ///   seeMoreLabel: 'See more',
  /// );
  /// ```
  static String? computeCollapsedTextForSeeMore({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    String seeMoreLabel = SeeMoreTextConstants.defaultSeeMoreText,
    TextDirection textDirection = TextDirection.ltr,
    TextAlign textAlign = TextAlign.left,
  }) {
    // Validate input parameters
    if (!_validateInputs(text, maxWidth, maxLines)) {
      return null;
    }

    // Check if the original text fits without truncation
    if (!_doesTextExceedConstraints(
      text: text,
      style: style,
      maxWidth: maxWidth,
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign,
    )) {
      return null; // No truncation needed
    }

    // Find the optimal truncation point using binary search
    return _findOptimalTruncationPoint(
      text: text,
      style: style,
      maxWidth: maxWidth,
      maxLines: maxLines,
      seeMoreLabel: seeMoreLabel,
      textDirection: textDirection,
      textAlign: textAlign,
    );
  }

  /// Validates the input parameters for text measurement.
  static bool _validateInputs(String text, double maxWidth, int maxLines) {
    return text.isNotEmpty && maxWidth > 0 && maxLines >= SeeMoreTextConstants.minLines;
  }

  /// Checks if the given text exceeds the specified constraints.
  static bool _doesTextExceedConstraints({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {
    final painter = _createTextPainter(
      text: text,
      style: style,
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign,
    );

    painter.layout(maxWidth: maxWidth);
    final exceedsConstraints = painter.didExceedMaxLines;
    painter.dispose();

    return exceedsConstraints;
  }

  /// Uses binary search to find the optimal truncation point.
  static String? _findOptimalTruncationPoint({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    required String seeMoreLabel,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {
    final suffix = '${SeeMoreTextConstants.defaultEllipsis}$seeMoreLabel';

    int left = 0;
    int right = text.length;
    int bestTruncationPoint = 0;

    while (left <= right) {
      final mid = (left + right) >> 1; // Equivalent to (left + right) ~/ 2

      final candidateText = text.substring(0, mid) + suffix;

      if (_doesTextFitConstraints(
        text: candidateText,
        style: style,
        maxWidth: maxWidth,
        maxLines: maxLines,
        textDirection: textDirection,
        textAlign: textAlign,
      )) {
        bestTruncationPoint = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    // Ensure we don't return an empty result or truncate to nothing
    bestTruncationPoint = bestTruncationPoint.clamp(1, text.length);

    return text.substring(0, bestTruncationPoint);
  }

  /// Checks if the given text fits within the specified constraints.
  static bool _doesTextFitConstraints({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {
    final painter = _createTextPainter(
      text: text,
      style: style,
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign,
    );

    painter.layout(maxWidth: maxWidth);
    final fitsConstraints = !painter.didExceedMaxLines;
    painter.dispose();

    return fitsConstraints;
  }

  /// Creates a configured [TextPainter] for text measurement.
  static TextPainter _createTextPainter({
    required String text,
    required TextStyle style,
    required int maxLines,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      ellipsis: '…', // Unicode ellipsis character
    );
  }

  /// Measures the size of text without any line constraints.
  ///
  /// This method is useful for determining the natural size of text content.
  @visibleForTesting
  static Size measureTextSize({
    required String text,
    required TextStyle style,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
    );

    painter.layout();
    final size = painter.size;
    painter.dispose();

    return size;
  }
}
