// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Constants used throughout the see_more_text package.
abstract class SeeMoreTextConstants {
  /// Default maximum number of lines before text is collapsed.
  static const int defaultMaxLines = 4;

  /// Default animation duration for expand/collapse transitions.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);

  /// Default "see more" label text.
  static const String defaultSeeMoreText = 'See more';

  /// Default "see less" label text.
  static const String defaultSeeLessText = 'See less';

  /// Default ellipsis text.
  static const String defaultEllipsis = '... ';

  /// Default spacer text.
  static const String defaultSpacer = '  ';

  /// Minimum number of lines allowed.
  static const int minLines = 1;

  /// Regular expression pattern for matching URLs.
  static const String urlPattern = r'(https?://[a-zA-Z0-9./?=_-]+)';

  /// Regular expression pattern for matching hashtags.
  static const String hashtagPattern = r'(#[a-zA-Z0-9_]+)';

  /// Regular expression pattern for matching mentions.
  static const String mentionPattern = r'(@[a-zA-Z0-9_]+)';
}
