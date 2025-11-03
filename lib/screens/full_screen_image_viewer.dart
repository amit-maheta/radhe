import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Center(
                child: PinchZoom(
                  // resetDuration: const Duration(milliseconds: 200),
                  maxScale: 2.5,
                  zoomEnabled: true,
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),

          // Page indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.imageUrls.length,
                effect: WormEffect(
                  dotColor: Colors.grey.shade600,
                  activeDotColor: Colors.white,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
