// Copyright 2025 Flutter Community. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'linkify.dart';
import 'models/text_span_config.dart';
import 'text_measure.dart';
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
      ..add(
          DiagnosticsProperty<Duration>('animationDuration', animationDuration))
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve));
  }
}

/// The private state class for [SeeMoreText].
class _SeeMoreTextState extends State<SeeMoreText>
    with TickerProviderStateMixin {
  /// Whether the text is currently in expanded state.
  bool _isExpanded = false;

  /// Cache for the processed text content.
  String? _processedText;

  /// Cache for the collapsed text version.
  String? _collapsedText;

  /// Cache for the layout constraints.
  BoxConstraints? _cachedConstraints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _buildContent(context, constraints),
    );
  }

  /// Builds the main content based on the current state and constraints.
  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    // Process text content if needed
    _updateProcessedTextIfNeeded();

    // Update collapsed text if constraints changed
    _updateCollapsedTextIfNeeded(context, constraints);

    final textSpanConfig = _createTextSpanConfig(context);
    final displayText = _getDisplayText();
    final isOverflowing = _isTextOverflowing();

    final textSpans = _buildTextSpans(
      text: displayText,
      config: textSpanConfig,
      isOverflowing: isOverflowing,
    );

    return _buildAnimatedContent(
      textSpans: textSpans,
      style: textSpanConfig.textStyle!,
    );
  }

  /// Updates the processed text cache if the text has changed.
  void _updateProcessedTextIfNeeded() {
    // Since we now use plain text, no HTML processing needed
    final processedText = widget.text;

    if (_processedText != processedText) {
      _processedText = processedText;
      _collapsedText = null; // Invalidate collapsed text cache
    }
  }

  /// Updates the collapsed text cache if constraints have changed.
  void _updateCollapsedTextIfNeeded(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (_cachedConstraints == constraints && _collapsedText != null) {
      return; // No need to recalculate
    }

    _cachedConstraints = constraints;
    final textStyle = _getEffectiveTextStyle(context);

    _collapsedText = TextMeasure.computeCollapsedTextForSeeMore(
      text: _processedText!,
      style: textStyle,
      maxWidth: constraints.maxWidth,
      maxLines: widget.maxLines,
      seeMoreLabel: widget.seeMoreText,
      textDirection: Directionality.of(context),
      textAlign: widget.textAlign,
    );
  }

  /// Creates the text span configuration for the current context.
  TextSpanConfig _createTextSpanConfig(BuildContext context) {
    final textStyle = _getEffectiveTextStyle(context);
    final linkStyle = _getEffectiveLinkStyle(context, textStyle);

    return TextSpanConfig(
      textStyle: textStyle,
      linkStyle: linkStyle,
      seeMoreText: widget.seeMoreText,
      seeLessText: widget.seeLessText,
    );
  }

  /// Gets the effective text style, with black as default color.
  TextStyle _getEffectiveTextStyle(BuildContext context) {
    return widget.textStyle ??
        DefaultTextStyle.of(context).style.copyWith(color: Colors.black);
  }

  /// Gets the effective link style, falling back to theme primary color.
  TextStyle _getEffectiveLinkStyle(BuildContext context, TextStyle baseStyle) {
    return widget.linkStyle ??
        baseStyle.copyWith(
          color: Theme.of(context).colorScheme.primary,
        );
  }

  /// Gets the text to display based on the current state.
  String _getDisplayText() {
    if (_isExpanded || !_isTextOverflowing()) {
      return _processedText!;
    }
    return _collapsedText!;
  }

  /// Checks if the text is overflowing and needs truncation.
  bool _isTextOverflowing() {
    return _collapsedText != null;
  }

  /// Gets the effective max lines to ensure toggle text is visible.
  int _getEffectiveMaxLines() {
    if (_isExpanded) {
      return widget.maxLines; // This won't be used anyway when expanded
    }

    // If text is overflowing and we need to show "see more",
    // allow one extra line to ensure the toggle text is visible
    if (_isTextOverflowing()) {
      return widget.maxLines + 1;
    }

    return widget.maxLines;
  }

  /// Builds the list of text spans with appropriate styling and interactions.
  List<InlineSpan> _buildTextSpans({
    required String text,
    required TextSpanConfig config,
    required bool isOverflowing,
  }) {
    final spans = <InlineSpan>[
      ...Linkify.buildClickableTextSpans(
        text: text,
        style: config.textStyle!,
        linkStyle: config.linkStyle,
        onUrlTap: widget.onUrlTap,
        onHashtagTap: widget.onHashtagTap,
        onMentionTap: widget.onMentionTap,
        onTextTap:
            widget.enableTextTapToggle && isOverflowing ? _handleToggle : null,
      ),
    ];

    // Add see more/less links if text is overflowing
    if (isOverflowing) {
      _addToggleSpans(spans, config);
    }

    return spans;
  }

  /// Adds the see more/see less spans to the text spans list.
  void _addToggleSpans(List<InlineSpan> spans, TextSpanConfig config) {
    if (!_isExpanded) {
      // Add "see more" link
      spans
        ..add(TextSpan(text: config.ellipsis, style: config.textStyle))
        ..add(TextSpan(
          text: config.seeMoreText,
          style: config.linkStyle,
          recognizer: _createTapRecognizer(_handleToggle),
        ));
    } else {
      // Add "see less" link
      spans
        ..add(TextSpan(text: config.spacer, style: config.textStyle))
        ..add(TextSpan(
          text: config.seeLessText,
          style: config.linkStyle,
          recognizer: _createTapRecognizer(_handleToggle),
        ));
    }
  }

  /// Builds the animated content wrapper.
  Widget _buildAnimatedContent({
    required List<InlineSpan> textSpans,
    required TextStyle style,
  }) {
    // Calculate the effective max lines to accommodate the toggle text
    final effectiveMaxLines = _getEffectiveMaxLines();

    return AnimatedSize(
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      alignment: Alignment.topLeft,
      child: widget.enableSelection
          ? SelectableText.rich(
              TextSpan(children: textSpans, style: style),
              maxLines: _isExpanded ? null : effectiveMaxLines,
              textAlign: widget.textAlign,
              scrollPhysics: const NeverScrollableScrollPhysics(),
            )
          : RichText(
              text: TextSpan(children: textSpans, style: style),
              maxLines: _isExpanded ? null : effectiveMaxLines,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.clip,
              textAlign: widget.textAlign,
            ),
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
