// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Configuration for text span styling and behavior.
///
/// This class encapsulates all styling options for different types of text
/// spans in the [SeeMoreText] widget.
@immutable
class TextSpanConfig {
  /// Creates a text span configuration.
  const TextSpanConfig({
    this.textStyle,
    this.linkStyle,
    this.seeMoreText = 'See more',
    this.seeLessText = 'See less',
    this.ellipsis = '... ',
    this.spacer = '  ',
  });

  /// The default text style for normal text.
  final TextStyle? textStyle;

  /// The text style for clickable elements (URLs, hashtags, mentions).
  final TextStyle? linkStyle;

  /// The text to display for expanding collapsed content.
  final String seeMoreText;

  /// The text to display for collapsing expanded content.
  final String seeLessText;

  /// The ellipsis text to show before the "see more" link.
  final String ellipsis;

  /// The spacer text between content and "see less" link.
  final String spacer;

  /// Creates a copy of this configuration with the given fields replaced.
  TextSpanConfig copyWith({
    TextStyle? textStyle,
    TextStyle? linkStyle,
    String? seeMoreText,
    String? seeLessText,
    String? ellipsis,
    String? spacer,
  }) {
    return TextSpanConfig(
      textStyle: textStyle ?? this.textStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      seeMoreText: seeMoreText ?? this.seeMoreText,
      seeLessText: seeLessText ?? this.seeLessText,
      ellipsis: ellipsis ?? this.ellipsis,
      spacer: spacer ?? this.spacer,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextSpanConfig &&
        other.textStyle == textStyle &&
        other.linkStyle == linkStyle &&
        other.seeMoreText == seeMoreText &&
        other.seeLessText == seeLessText &&
        other.ellipsis == ellipsis &&
        other.spacer == spacer;
  }

  @override
  int get hashCode {
    return Object.hash(
      textStyle,
      linkStyle,
      seeMoreText,
      seeLessText,
      ellipsis,
      spacer,
    );
  }

  @override
  String toString() {
    return 'TextSpanConfig('
        'textStyle: $textStyle, '
        'linkStyle: $linkStyle, '
        'seeMoreText: $seeMoreText, '
        'seeLessText: $seeLessText, '
        'ellipsis: $ellipsis, '
        'spacer: $spacer'
        ')';
  }
}
