// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'types/callbacks.dart';

/// A utility class for converting text with URLs, hashtags, and mentions
/// into interactive text spans.
///
/// This class provides static methods to parse text and create [TextSpan]
/// objects with appropriate gesture recognizers for clickable elements.
abstract class Linkify {
  // Private constructor to prevent instantiation
  Linkify._();

  /// Regular expression for matching URLs.
  static final RegExp _urlRegex = RegExp(
    SeeMoreTextConstants.urlPattern,
    caseSensitive: false,
  );

  /// Regular expression for matching hashtags.
  static final RegExp _hashtagRegex = RegExp(
    SeeMoreTextConstants.hashtagPattern,
  );

  /// Regular expression for matching mentions.
  static final RegExp _mentionRegex = RegExp(
    SeeMoreTextConstants.mentionPattern,
  );

  /// Converts text into a list of [InlineSpan] objects with clickable elements.
  ///
  /// This method parses the input [text] and creates interactive spans for:
  /// - URLs (http:// or https://)
  /// - Hashtags (starting with #)
  /// - Mentions (starting with @)
  ///
  /// Parameters:
  /// - [text]: The text to be processed
  /// - [style]: The default text style for non-clickable text
  /// - [linkStyle]: Optional style for clickable elements (defaults to [style])
  /// - [onUrlTap]: Callback for URL taps
  /// - [onHashtagTap]: Callback for hashtag taps
  /// - [onMentionTap]: Callback for mention taps
  /// - [onTextTap]: Callback for tapping on non-clickable text
  ///
  /// Returns a list of [InlineSpan] objects that can be used in a [RichText]
  /// or [Text.rich] widget.
  static List<InlineSpan> buildClickableTextSpans({
    required String text,
    required TextStyle style,
    TextStyle? linkStyle,
    UrlTapCallback? onUrlTap,
    HashtagTapCallback? onHashtagTap,
    MentionTapCallback? onMentionTap,
    GestureTapCallback? onTextTap,
  }) {
    if (text.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final spans = <InlineSpan>[];
    int currentPosition = 0;

    // Find all matches and sort them by position
    final matches = _findAllMatches(text);

    for (final match in matches) {
      // Add normal text before the match
      if (match.start > currentPosition) {
        final normalText = text.substring(currentPosition, match.start);
        spans.add(_createTextSpan(
          text: normalText,
          style: style,
          onTap: onTextTap,
        ));
      }

      // Add the matched clickable element
      final matchedText = text.substring(match.start, match.end);
      final clickableSpan = _createClickableSpan(
        text: matchedText,
        style: linkStyle ?? style,
        onUrlTap: onUrlTap,
        onHashtagTap: onHashtagTap,
        onMentionTap: onMentionTap,
      );

      if (clickableSpan != null) {
        spans.add(clickableSpan);
      }

      currentPosition = match.end;
    }

    // Add remaining text after the last match
    if (currentPosition < text.length) {
      final remainingText = text.substring(currentPosition);
      spans.add(_createTextSpan(
        text: remainingText,
        style: style,
        onTap: onTextTap,
      ));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: style)] : spans;
  }

  /// Finds all matches for URLs, hashtags, and mentions in the text.
  static List<RegExpMatch> _findAllMatches(String text) {
    final matches = <RegExpMatch>[
      ..._urlRegex.allMatches(text),
      ..._hashtagRegex.allMatches(text),
      ..._mentionRegex.allMatches(text),
    ];

    // Sort matches by starting position to process them in order
    matches.sort((a, b) => a.start.compareTo(b.start));

    return matches;
  }

  /// Creates a text span with an optional tap callback.
  static TextSpan _createTextSpan({
    required String text,
    required TextStyle style,
    GestureTapCallback? onTap,
  }) {
    return TextSpan(
      text: text,
      style: style,
      recognizer: onTap != null ? _createTapRecognizer(onTap) : null,
    );
  }

  /// Creates a clickable span based on the type of matched text.
  static TextSpan? _createClickableSpan({
    required String text,
    required TextStyle style,
    UrlTapCallback? onUrlTap,
    HashtagTapCallback? onHashtagTap,
    MentionTapCallback? onMentionTap,
  }) {
    if (_urlRegex.hasMatch(text)) {
      return _createUrlSpan(text, style, onUrlTap);
    } else if (_hashtagRegex.hasMatch(text)) {
      return _createHashtagSpan(text, style, onHashtagTap);
    } else if (_mentionRegex.hasMatch(text)) {
      return _createMentionSpan(text, style, onMentionTap);
    }
    return null;
  }

  /// Creates a text span for a URL with tap handling.
  static TextSpan _createUrlSpan(
    String url,
    TextStyle style,
    UrlTapCallback? onUrlTap,
  ) {
    return TextSpan(
      text: url,
      style: style,
      recognizer: onUrlTap != null ? _createTapRecognizer(() => onUrlTap(url)) : null,
    );
  }

  /// Creates a text span for a hashtag with tap handling.
  static TextSpan _createHashtagSpan(
    String hashtag,
    TextStyle style,
    HashtagTapCallback? onHashtagTap,
  ) {
    return TextSpan(
      text: hashtag,
      style: style,
      recognizer: onHashtagTap != null ? _createTapRecognizer(() => onHashtagTap(hashtag)) : null,
    );
  }

  /// Creates a text span for a mention with tap handling.
  static TextSpan _createMentionSpan(
    String mention,
    TextStyle style,
    MentionTapCallback? onMentionTap,
  ) {
    return TextSpan(
      text: mention,
      style: style,
      recognizer: onMentionTap != null ? _createTapRecognizer(() => onMentionTap(mention)) : null,
    );
  }

  /// Creates a tap gesture recognizer with the given callback.
  static TapGestureRecognizer _createTapRecognizer(VoidCallback onTap) {
    return TapGestureRecognizer()..onTap = onTap;
  }
}
