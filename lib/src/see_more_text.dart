// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'linkify.dart';
import 'models/text_span_config.dart';
import 'types/callbacks.dart';

/// A widget that displays text with expandable/collapsible functionality.
///
/// [SeeMoreText] automatically truncates long text and provides "See more" and
/// "See less" links to toggle between collapsed and expanded states. It supports
/// clickable URLs, hashtags, mentions, and text selection.
///
/// ## Features
///
/// - **Automatic truncation**: Text is automatically truncated based on [maxLines]
/// - **Interactive elements**: Supports clickable URLs, hashtags, and mentions
/// - **Text selection**: Long press to select text (can be disabled)
/// - **Customizable styling**: Flexible text and link styling options
/// - **Smooth animations**: Animated expand/collapse transitions
/// - **Accessibility**: Follows Flutter's accessibility guidelines
///
/// ## Example Usage
///
/// ```dart
/// SeeMoreText(
///   text: 'This is a long text with https://example.com links #hashtags @mentions',
///   maxLines: 3,
///   seeMoreText: 'Read more',
///   seeLessText: 'Read less',
///   enableSelection: true, // Enable text selection
///   onUrlTap: (url) => launchUrl(url),
///   onHashtagTap: (hashtag) => navigateToHashtag(hashtag),
///   onMentionTap: (mention) => navigateToProfile(mention),
/// )
/// ```
class SeeMoreText extends StatefulWidget {
  /// Creates a [SeeMoreText] widget.
  ///
  /// The [text] parameter is required and contains the text content to display.
  /// All other parameters are optional and have sensible defaults.
  const SeeMoreText({
    super.key,
    required this.text,
    this.maxLines = SeeMoreTextConstants.defaultMaxLines,
    this.textStyle,
    this.linkStyle,
    this.seeMoreText = SeeMoreTextConstants.defaultSeeMoreText,
    this.seeLessText = SeeMoreTextConstants.defaultSeeLessText,
    this.onUrlTap,
    this.onHashtagTap,
    this.onMentionTap,
    this.onToggle,
    this.textAlign = TextAlign.start,
    this.enableTextTapToggle = true,
    this.enableSelection = true,
    this.animationDuration = SeeMoreTextConstants.defaultAnimationDuration,
    this.animationCurve = Curves.easeInOut,
  }) : assert(
          maxLines >= SeeMoreTextConstants.minLines,
          'maxLines must be at least ${SeeMoreTextConstants.minLines}',
        );

  /// The text content to display.
  ///
  /// This content will be processed to detect and make clickable
  /// URLs, hashtags, and mentions.
  final String text;

  /// The maximum number of lines to display in the collapsed state.
  ///
  /// Must be at least [SeeMoreTextConstants.minLines]. When the content
  /// exceeds this number of lines, it will be truncated and a "see more"
  /// link will be shown.
  final int maxLines;

  /// The text style for normal (non-clickable) text.
  ///
  /// If not provided, defaults to the ambient [DefaultTextStyle].
  final TextStyle? textStyle;

  /// The text style for clickable elements (URLs, hashtags, mentions).
  ///
  /// If not provided, defaults to [textStyle] with the primary color
  /// from the current theme.
  final TextStyle? linkStyle;

  /// The text to display for expanding collapsed content.
  ///
  /// Defaults to [SeeMoreTextConstants.defaultSeeMoreText].
  final String seeMoreText;

  /// The text to display for collapsing expanded content.
  ///
  /// Defaults to [SeeMoreTextConstants.defaultSeeLessText].
  final String seeLessText;

  /// Callback invoked when a URL is tapped.
  ///
  /// The callback receives the URL that was tapped as a parameter.
  final UrlTapCallback? onUrlTap;

  /// Callback invoked when a hashtag is tapped.
  ///
  /// The callback receives the hashtag (including #) that was tapped.
  final HashtagTapCallback? onHashtagTap;

  /// Callback invoked when a mention is tapped.
  ///
  /// The callback receives the mention (including @) that was tapped.
  final MentionTapCallback? onMentionTap;

  /// Callback invoked when the expand/collapse state changes.
  ///
  /// The callback receives a boolean indicating whether the text is expanded.
  final ToggleCallback? onToggle;

  /// The alignment of the text content.
  ///
  /// Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// Whether tapping on non-clickable text should toggle expand/collapse.
  ///
  /// When true, tapping anywhere on the text (except on clickable elements)
  /// will toggle between expanded and collapsed states. When false, only
  /// the "see more"/"see less" links can trigger the toggle.
  ///
  /// Defaults to true.
  final bool enableTextTapToggle;

  /// Whether the text should be selectable.
  ///
  /// When true, users can long press to select text. When false,
  /// text selection is disabled.
  ///
  /// Defaults to true.
  final bool enableSelection;

  /// The duration of the expand/collapse animation.
  ///
  /// Defaults to [SeeMoreTextConstants.defaultAnimationDuration].
  final Duration animationDuration;

  /// The curve used for the expand/collapse animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  @override
  State<SeeMoreText> createState() => _SeeMoreTextState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(IntProperty('maxLines', maxLines))
      ..add(DiagnosticsProperty<TextStyle>('textStyle', textStyle))
      ..add(DiagnosticsProperty<TextStyle>('linkStyle', linkStyle))
      ..add(StringProperty('seeMoreText', seeMoreText))
      ..add(StringProperty('seeLessText', seeLessText))
      ..add(EnumProperty<TextAlign>('textAlign', textAlign))
      ..add(FlagProperty(
        'enableTextTapToggle',
        value: enableTextTapToggle,
        ifTrue: 'text tap enabled',
        ifFalse: 'text tap disabled',
      ))
      ..add(FlagProperty(
        'enableSelection',
        value: enableSelection,
        ifTrue: 'selection enabled',
        ifFalse: 'selection disabled',
      ))
      ..add(DiagnosticsProperty<Duration>('animationDuration', animationDuration))
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve));
  }
}

/// The private state class for [SeeMoreText].
class _SeeMoreTextState extends State<SeeMoreText> {
  /// Whether the text is currently in expanded state.
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _buildContent(context, constraints),
    );
  }

  /// Builds the main content based on the current state and constraints.
  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    final textStyle = _getEffectiveTextStyle(context);
    final linkStyle = _getEffectiveLinkStyle(context, textStyle);

    final textSpanConfig = TextSpanConfig(
      textStyle: textStyle,
      linkStyle: linkStyle,
      seeMoreText: widget.seeMoreText,
      seeLessText: widget.seeLessText,
    );

    return _buildAnimatedContent(
      context: context,
      constraints: constraints,
      config: textSpanConfig,
    );
  }

  /// Builds the content with proper text measurement and trimming.
  Widget _buildAnimatedContent({
    required BuildContext context,
    required BoxConstraints constraints,
    required TextSpanConfig config,
  }) {
    final textDirection = Directionality.of(context);
    final textAlign = widget.textAlign;

    // Create text painter for full text
    final fullTextPainter = TextPainter(
      text: TextSpan(text: widget.text, style: config.textStyle),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: widget.maxLines,
    );
    fullTextPainter.layout(maxWidth: constraints.maxWidth);

    final needsTruncation = fullTextPainter.didExceedMaxLines;

    if (!needsTruncation) {
      // No truncation needed
      final textSpans = Linkify.buildClickableTextSpans(
        text: widget.text,
        style: config.textStyle!,
        linkStyle: config.linkStyle,
        onUrlTap: widget.onUrlTap,
        onHashtagTap: widget.onHashtagTap,
        onMentionTap: widget.onMentionTap,
        onTextTap: widget.enableTextTapToggle ? _handleToggle : null,
      );

      return _buildRichText(textSpans, config, null);
    }

    // Calculate truncation point
    final truncationResult = _calculateTruncationPoint(
      fullText: widget.text,
      style: config.textStyle!,
      maxWidth: constraints.maxWidth,
      maxLines: widget.maxLines,
      seeMoreText: widget.seeMoreText,
      textDirection: textDirection,
      textAlign: textAlign,
    );

    final displayText = _isExpanded ? widget.text : truncationResult.truncatedText;
    final textSpans = _buildTextSpans(
      text: displayText,
      config: config,
      isExpanded: _isExpanded,
      needsTruncation: needsTruncation,
      needsSuffix: truncationResult.needsSuffix,
    );

    final effectiveMaxLines = _isExpanded ? null : widget.maxLines;

    return _buildRichText(textSpans, config, effectiveMaxLines);
  }

  /// Calculates the optimal truncation point using a simpler approach.
  _TruncationResult _calculateTruncationPoint({
    required String fullText,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    required String seeMoreText,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {
    final suffix = '...$seeMoreText';

    // Measure the suffix
    final suffixPainter = TextPainter(
      text: TextSpan(text: suffix, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
    );
    suffixPainter.layout(maxWidth: maxWidth);

    // Measure full text
    final textPainter = TextPainter(
      text: TextSpan(text: fullText, style: style),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
    );
    textPainter.layout(maxWidth: maxWidth);

    var linkLongerThanLine = false;
    int endIndex;

    if (suffixPainter.size.width < maxWidth) {
      // Calculate available space for text
      final suffixWidth = suffixPainter.size.width;
      final textSize = textPainter.size;
      final pos = textPainter.getPositionForOffset(
        Offset(
          textDirection == TextDirection.rtl ? suffixWidth : textSize.width - suffixWidth,
          textSize.height,
        ),
      );
      endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
    } else {
      // Suffix is too long, use the end of available lines
      final pos = textPainter.getPositionForOffset(
        textPainter.size.bottomLeft(Offset.zero),
      );
      endIndex = pos.offset;
      linkLongerThanLine = true;
    }

    // Ensure we don't go beyond text length
    endIndex = endIndex.clamp(0, fullText.length);

    // Get the truncated text
    final truncatedText = fullText.substring(0, endIndex);

    return _TruncationResult(
      truncatedText: truncatedText,
      needsSuffix: !linkLongerThanLine,
    );
  }

  /// Builds the list of text spans with appropriate styling and interactions.
  List<InlineSpan> _buildTextSpans({
    required String text,
    required TextSpanConfig config,
    required bool isExpanded,
    required bool needsTruncation,
    required bool needsSuffix,
  }) {
    final spans = <InlineSpan>[
      ...Linkify.buildClickableTextSpans(
        text: text,
        style: config.textStyle!,
        linkStyle: config.linkStyle,
        onUrlTap: widget.onUrlTap,
        onHashtagTap: widget.onHashtagTap,
        onMentionTap: widget.onMentionTap,
        onTextTap: widget.enableTextTapToggle && needsTruncation ? _handleToggle : null,
      ),
    ];

    // Add toggle links if needed
    if (needsTruncation) {
      if (!isExpanded) {
        if (needsSuffix) {
          spans.addAll([
            TextSpan(text: '...', style: config.textStyle),
            TextSpan(
              text: config.seeMoreText,
              style: config.linkStyle,
              recognizer: _createTapRecognizer(_handleToggle),
            ),
          ]);
        } else {
          spans.add(
            TextSpan(
              text: config.seeMoreText,
              style: config.linkStyle,
              recognizer: _createTapRecognizer(_handleToggle),
            ),
          );
        }
      } else {
        spans.addAll([
          TextSpan(text: '  ', style: config.textStyle),
          TextSpan(
            text: config.seeLessText,
            style: config.linkStyle,
            recognizer: _createTapRecognizer(_handleToggle),
          ),
        ]);
      }
    }

    return spans;
  }

  /// Builds the RichText widget with proper configuration.
  Widget _buildRichText(
    List<InlineSpan> textSpans,
    TextSpanConfig config,
    int? maxLines,
  ) {
    final richText = RichText(
      text: TextSpan(children: textSpans, style: config.textStyle),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.clip : TextOverflow.visible,
      textAlign: widget.textAlign,
      softWrap: true,
    );

    if (widget.enableSelection) {
      return SelectionArea(child: richText);
    }

    return richText;
  }

  /// Gets the effective text style, with black as default color.
  TextStyle _getEffectiveTextStyle(BuildContext context) {
    return widget.textStyle ?? DefaultTextStyle.of(context).style.copyWith(color: Colors.black);
  }

  /// Gets the effective link style, falling back to theme primary color.
  TextStyle _getEffectiveLinkStyle(BuildContext context, TextStyle baseStyle) {
    return widget.linkStyle ??
        baseStyle.copyWith(
          color: Theme.of(context).colorScheme.primary,
        );
  }

  /// Handles the toggle between expanded and collapsed states.
  void _handleToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onToggle?.call(_isExpanded);
  }

  /// Creates a tap gesture recognizer with the given callback.
  TapGestureRecognizer _createTapRecognizer(VoidCallback onTap) {
    return TapGestureRecognizer()..onTap = onTap;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'isExpanded',
      value: _isExpanded,
      ifTrue: 'expanded',
      ifFalse: 'collapsed',
    ));
  }
}

/// Result of text truncation calculation.
class _TruncationResult {
  const _TruncationResult({
    required this.truncatedText,
    required this.needsSuffix,
  });

  final String truncatedText;
  final bool needsSuffix;
}
