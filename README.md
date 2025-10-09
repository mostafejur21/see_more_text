# See More Text

[![Pub Version](https://img.shields.io/pub/v/see_more_text.svg)](https://pub.dev/packages/see_more_text)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A simple Flutter widget that automatically truncates long text and lets users expand it with "See more" / "See less" buttons.

Perfect for social media posts, articles, product descriptions, and anywhere you need to show long text in a compact way.

## Features

- ✅ **Auto-truncate** long text after specified number of lines
- ✅ **Clickable links** - URLs, hashtags (#flutter), and mentions (@username)
- ✅ **Text selection** - Long press to select text
- ✅ **Smooth animations** when expanding/collapsing
- ✅ **Highly customizable** styling
- ✅ **Zero setup** - works out of the box

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  see_more_text: ^1.1.1
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
SeeMoreText(
  text: 'Your very long text that needs to be truncated...',
  maxLines: 3,
)
```

## Examples

### Social Media Post

```dart
SeeMoreText(
  text: 'Just launched my new Flutter app! 🚀 Check it out at https://myapp.com and follow me @flutter_dev for updates! #FlutterDev #MobileApp',
  maxLines: 2,
  onUrlTap: (url) {
    // Open the URL in browser
    launchUrl(Uri.parse(url));
  },
  onHashtagTap: (hashtag) {
    // Navigate to hashtag page
    print('Tapped on $hashtag');
  },
  onMentionTap: (mention) {
    // Show user profile
    print('Tapped on $mention');
  },
)
```

### Custom Styling

```dart
SeeMoreText(
  text: 'Beautiful text with custom styling and colors...',
  maxLines: 2,
  textStyle: TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  ),
  linkStyle: TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  ),
  seeMoreText: 'Read more',
  seeLessText: 'Show less',
)
```

### Disable Text Selection

```dart
SeeMoreText(
  text: 'Sometimes you don\'t want users to select text...',
  maxLines: 3,
  enableSelection: false, // Disable text selection
)
```

## All Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | `String` | **required** | The text content to display |
| `maxLines` | `int` | `3` | Number of lines before truncation |
| `textStyle` | `TextStyle?` | `null` | Style for regular text |
| `linkStyle` | `TextStyle?` | `null` | Style for clickable links |
| `seeMoreText` | `String` | `'See more'` | Text for expand button |
| `seeLessText` | `String` | `'See less'` | Text for collapse button |
| `onUrlTap` | `Function(String)?` | `null` | Called when URL is tapped |
| `onHashtagTap` | `Function(String)?` | `null` | Called when hashtag is tapped |
| `onMentionTap` | `Function(String)?` | `null` | Called when mention is tapped |
| `onToggle` | `Function(bool)?` | `null` | Called when text expands/collapses |
| `textAlign` | `TextAlign` | `TextAlign.start` | Text alignment |
| `enableSelection` | `bool` | `true` | Allow text selection |
| `enableTextTapToggle` | `bool` | `true` | Tap text to expand/collapse |

## Tips

- Use 2-3 lines for mobile screens, 3-4 for tablets
- Keep `seeMoreText` and `seeLessText` short and clear
- Set `enableSelection: false` for cards or buttons where selection would interfere
- Use callbacks to handle link taps for navigation or analytics

## License

BSD-3-Clause License

## 📊 Performance & Best Practices

### ⚡ Optimization Tips

1. **Smart Line Limits**: Use 2-4 lines for mobile, 3-6 for tablets
2. **Efficient Callbacks**: Keep tap handlers lightweight and async
3. **Memory Management**: Widget automatically handles text measurement caching
4. **Smooth Animations**: Built-in transitions work perfectly with `AnimatedSize`

## License

MIT License

### 🎯 Use Case Matrix

| Use Case | Recommended maxLines | Features to Enable |
|----------|---------------------|-------------------|
| Social Media Posts | 2-3 | Links, hashtags, mentions |
| News Articles | 3-4 | URLs, custom triggers |
| Product Descriptions | 2-3 | Clean HTML, custom styling |
| Comments/Reviews | 2-4 | Links, mentions, emojis |
| Documentation | 4-6 | URLs, custom formatting |

## 🌍 Platform Support

| Platform | Support | Features |
|----------|---------|----------|
| 📱 **iOS** | ✅ Full | All features including haptic feedback |
| 🤖 **Android** | ✅ Full | Native link handling, material design |
| 🌐 **Web** | ✅ Full | Hover effects, keyboard navigation |
| 🖥️ **macOS** | ✅ Full | Right-click context menus |
| 🪟 **Windows** | ✅ Full | Native text selection |
| 🐧 **Linux** | ✅ Full | Complete feature parity |

## 🧪 Testing & Quality

```bash
# Run the comprehensive test suite
flutter test

# Check code quality
flutter analyze

# Performance profiling
flutter test --coverage
```

**Quality Metrics:**
- ✅ Zero Linting Issues
- ✅ Memory Leak Free
- ✅ Performance Optimized
- ✅ Accessibility Compliant

## 🤝 Contributing & Support

We love contributions! Whether it's:

- 🐛 **Bug Reports**: Help us improve by reporting issues
- 💡 **Feature Requests**: Share your ideas for new functionality
- 📖 **Documentation**: Help make our docs even better
- 🧪 **Testing**: Add test cases or find edge cases
- 💻 **Code**: Submit PRs with improvements or fixes

### Quick Development Setup

```bash
git clone https://github.com/mostafejur21/see_more_text.git
cd see_more_text
flutter pub get
flutter test
```

## 📜 License

**MIT License** - See [LICENSE](LICENSE) for details.

Free for commercial and personal use! 🎉

---

## � Made with Flutter

**See More Text** is crafted with love for the Flutter community. Star ⭐ the repo if it helps your project!

**Happy Coding!** 🚀✨
