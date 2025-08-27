import 'package:flutter/material.dart';
import 'package:see_more_text/see_more_text.dart';

void main() {
  runApp(const SeeMoreTextExampleApp());
}

class SeeMoreTextExampleApp extends StatelessWidget {
  const SeeMoreTextExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'See More Text Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 See More Text Examples'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('🚀 Basic Example'),
          _buildBasicExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('📱 Social Media Post'),
          _buildSocialMediaExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('📰 News Article'),
          _buildNewsExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('🛍️ Product Description'),
          _buildProductExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('🎨 Text Styling'),
          _buildStylingExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('🔗 Interactive Elements'),
          _buildInteractiveExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('📝 Text Selection'),
          _buildSelectionExample(),
          const SizedBox(height: 24),

          _buildSectionHeader('✨ Custom Styling'),
          _buildCustomStylingExample(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExampleCard({required Widget child, String? title}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicExample() {
    return _buildExampleCard(
      title: 'Simple text truncation with default settings',
      child: const SeeMoreText(
        text:
            'This is a basic example of the See More Text widget. It automatically truncates long content and provides a smooth expand/collapse experience. Perfect for blog posts, articles, descriptions, and any content that needs smart text management.',
        maxLines: 2,
      ),
    );
  }

  Widget _buildSocialMediaExample() {
    return _buildExampleCard(
      title: 'Social media post with interactive elements',
      child: SeeMoreText(
        text:
            'Just launched my new Flutter app! 🚀 Check it out at https://myawesomeapp.com and follow the journey with #FlutterDev #MobileApp. Special thanks to @flutter_team @google_dev for the amazing framework!',
        maxLines: 2,
        textStyle: const TextStyle(fontSize: 16, height: 1.4),
        linkStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
        onUrlTap: _handleUrlTap,
        onHashtagTap: _handleHashtagTap,
        onMentionTap: _handleMentionTap,
        onToggle: (isExpanded) {
          _showSnackBar('Post ${isExpanded ? 'expanded' : 'collapsed'}');
        },
      ),
    );
  }

  Widget _buildNewsExample() {
    return _buildExampleCard(
      title: 'News article with custom expand/collapse text',
      child: SeeMoreText(
        text:
            'Breaking News: Flutter 4.0 introduces revolutionary features that will change mobile development forever. The new rendering engine provides 40% better performance, enhanced web support, and seamless desktop integration.',
        maxLines: 3,
        seeMoreText: 'Read full article →',
        seeLessText: '← Show summary',
        textStyle: const TextStyle(fontSize: 15, height: 1.5),
        linkStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        onToggle: (isExpanded) {
          _showSnackBar('Article ${isExpanded ? 'expanded' : 'collapsed'}');
        },
      ),
    );
  }

  Widget _buildProductExample() {
    return _buildExampleCard(
      title: 'E-commerce product description',
      child: SeeMoreText(
        text:
            'Premium wireless headphones with industry-leading noise cancellation technology. Features include 30-hour battery life, premium leather and metal construction, crystal-clear sound quality with custom drivers, and seamless connectivity with all devices.',
        maxLines: 2,
        seeMoreText: 'View full details',
        seeLessText: 'Hide details',
        textStyle: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
        ),
        linkStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildStylingExample() {
    return Column(
      children: [
        _buildExampleCard(
          title: 'Standard text formatting',
          child: const SeeMoreText(
            text:
                'This text demonstrates standard formatting with links like https://flutter.dev that will be automatically detected and made clickable. The default black text color ensures optimal readability.',
            maxLines: 2,
            textStyle: TextStyle(fontSize: 15),
          ),
        ),
        _buildExampleCard(
          title: 'Custom text styling',
          child: const SeeMoreText(
            text:
                'This text shows custom styling options with different font weights, colors, and spacing. You can customize every aspect of the text appearance to match your app design perfectly.',
            maxLines: 2,
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.indigo,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveExample() {
    return _buildExampleCard(
      title: 'All interactive elements with custom callbacks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeeMoreText(
            text:
                'Test all interactive features: Visit https://flutter.dev for documentation, check out https://pub.dev for packages, follow #FlutterDev #Dart hashtags, and mention @flutter_team @dart_lang for questions.',
            maxLines: 3,
            textStyle: const TextStyle(fontSize: 15),
            linkStyle: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            onUrlTap: _handleUrlTap,
            onHashtagTap: _handleHashtagTap,
            onMentionTap: _handleMentionTap,
            onToggle: (isExpanded) {
              _showSnackBar('Text ${isExpanded ? 'expanded' : 'collapsed'}');
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap any URL, hashtag, or mention to see the interaction!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionExample() {
    return Column(
      children: [
        _buildExampleCard(
          title: 'Text selection enabled (default)',
          child: const SeeMoreText(
            text:
                'This text is selectable! Long press on any part of this text to start selecting. You can copy this text to clipboard and paste it elsewhere. Text selection works both in collapsed and expanded states.',
            maxLines: 2,
            enableSelection: true, // This is the default
            textStyle: TextStyle(fontSize: 15),
          ),
        ),
        _buildExampleCard(
          title: 'Text selection disabled',
          child: const SeeMoreText(
            text:
                'This text is NOT selectable. Try long pressing on this text - nothing will happen. This might be useful for read-only content where you want to prevent text selection.',
            maxLines: 2,
            enableSelection: false, // Disable text selection
            textStyle: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
        _buildExampleCard(
          title: 'Selection with interactive elements',
          child: const SeeMoreText(
            text:
                'You can select this text AND interact with links like https://flutter.dev, hashtags like #flutter, and mentions like @flutter_team. Long press to select, tap links to interact!',
            maxLines: 2,
            enableSelection: true,
            textStyle: TextStyle(fontSize: 15),
            linkStyle: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomStylingExample() {
    return _buildExampleCard(
      title: 'Custom styling with modern design',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SeeMoreText(
          text:
              'Experience the future of mobile development with cutting-edge tools and frameworks. Our platform provides everything you need to build, test, and deploy amazing applications that users love.',
          maxLines: 2,
          seeMoreText: '✨ Discover more',
          seeLessText: '↩️ Show less',
          textStyle: TextStyle(fontSize: 16, color: Colors.white, height: 1.6),
          linkStyle: TextStyle(
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _handleUrlTap(String url) {
    _showSnackBar('URL tapped: $url');
    // In a real app, you would use url_launcher here:
    // launchUrl(Uri.parse(url));
  }

  void _handleHashtagTap(String hashtag) {
    _showSnackBar('Hashtag tapped: $hashtag');
    // Navigate to hashtag feed or search
  }

  void _handleMentionTap(String mention) {
    _showSnackBar('Mention tapped: $mention');
    // Show user profile or send message
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
