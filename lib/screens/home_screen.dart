import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../widgets/feed_widget.dart';
import '../widgets/take_real_button.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPostedToday = false;

  @override
  void initState() {
    super.initState();
    _checkTodaysPost();
  }

  Future<void> _checkTodaysPost() async {
    final postService = context.read<PostService>();
    final hasPosted = await postService.checkHasPostedToday();
    setState(() {
      _hasPostedToday = hasPosted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RealNow'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: _hasPostedToday ? _buildFeedView() : _buildPrePostView(),
    );
  }

  Widget _buildPrePostView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white54,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Post today to see your friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TakeRealButton(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaptureScreen(),
                      ),
                    );
                    if (result == true) {
                      _checkTodaysPost();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedView() {
    return const FeedWidget();
  }
}