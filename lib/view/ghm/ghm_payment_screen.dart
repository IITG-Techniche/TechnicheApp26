import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class GHMPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final Function() onPaymentSuccess;

  const GHMPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.onPaymentSuccess,
  });

  @override
  State<GHMPaymentScreen> createState() => _GHMPaymentScreenState();
}

class _GHMPaymentScreenState extends State<GHMPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF181A20))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Can add a progress bar if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Let the user see the website's confirmation page
            if (request.url.contains('techniche.org.in/ghm/21confirm/')) {
              widget.onPaymentSuccess();
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D24),
        title: Text(
          "GLORY RUN PAYMENT",
          style: GoogleFonts.orbitron(
            color: const Color(0xFF00E5FF),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
            ),
        ],
      ),
    );
  }
}
