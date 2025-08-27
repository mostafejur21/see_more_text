// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Callback invoked when a URL is tapped.
///
/// The [url] parameter contains the URL that was tapped.
typedef UrlTapCallback = void Function(String url);

/// Callback invoked when a hashtag is tapped.
///
/// The [hashtag] parameter contains the hashtag that was tapped (including #).
typedef HashtagTapCallback = void Function(String hashtag);

/// Callback invoked when a mention is tapped.
///
/// The [mention] parameter contains the mention that was tapped (including @).
typedef MentionTapCallback = void Function(String mention);

/// Callback invoked when the expand/collapse state changes.
///
/// The [isExpanded] parameter indicates whether the text is now expanded.
typedef ToggleCallback = void Function(bool isExpanded);
