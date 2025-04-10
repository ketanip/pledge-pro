import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sponsor_karo/components/post/comment_section.dart';
import 'package:sponsor_karo/models/post.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/screens/ask_ai_screen.dart';
import 'package:sponsor_karo/screens/individual_chat_screen.dart';
import 'package:sponsor_karo/screens/user_profile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sponsor_karo/services/post_service.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  bool _isLiked = false, isBookmarked = false;
  int currentIndex = 0;
  late int likeCount;

  final PostService _postService = PostService();

  late PublicProfile _publicProfile;
  bool _isLoading = true;
  String currentUsername = '';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likeCount;
    loadData();
  }

  void loadData() async {
    final profile = await PublicProfileService().getPublicProfile(
      widget.post.username,
    );

    final userEmail = _firebaseAuth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in");
    }
    final username = userEmail.split('@').first.toLowerCase();

    final isLiked = await _postService.isPostLiked(widget.post.id, username);

    setState(() {
      _publicProfile = profile;
      _isLoading = false;
      currentUsername = username;
      likeCount = widget.post.likeCount;
      _isLiked = isLiked;
    });
  }

  void showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentSection(postId: widget.post.id),
    );
  }

  void toggleLike() async {
    if (_isLiked) {
      await _postService.unlikePost(widget.post.id, currentUsername);
    } else {
      await _postService.likePost(widget.post.id, currentUsername);
    }

    setState(() {
      _isLiked = !_isLiked;
      likeCount += _isLiked ? 1 : -1;
    });
  }

  void toggleBookmark() {
    setState(() => isBookmarked = !isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for keeping the state alive

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Card(
      color: colors.surface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primary,
                  child: ClipOval(
                    child:
                        _publicProfile.profilePic.isNotEmpty
                            ? Image.network(
                              _publicProfile.profilePic,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.person),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => UserProfileScreen(
                                username: widget.post.username,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      widget.post.username,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AskAIScreen(username: _publicProfile.username),
                      ),
                    );
                  },
                  icon: Icon(Icons.auto_awesome, color: colors.onSurface),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colors.onSurface),
                  onSelected: (value) async {
                    if (value == "Delete") {
                      await _postService.deletePost(widget.post.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Deleted successfully, refresh to see changes.")),
                      );
                    } else if (value == "Report") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Reported successfully")),
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem<String>(
                          value: "Report",
                          child: Text("Report"),
                        ),
                        if (currentUsername == _publicProfile.username)
                          const PopupMenuItem<String>(
                            value: "Delete",
                            child: Text("Delete"),
                          ),
                      ],
                ),
              ],
            ),
          ),

          // Image Carousel
          GestureDetector(
            onDoubleTap: toggleLike,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                CarouselSlider.builder(
                  itemCount: widget.post.imageUrls.length,
                  itemBuilder:
                      (_, index, __) => Image.network(
                        widget.post.imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                  options: CarouselOptions(
                    height: 350,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged:
                        (index, _) => setState(() => currentIndex = index),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentIndex + 1} of ${widget.post.imageUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? colors.error : colors.onSurface,
                    size: 30,
                  ),
                  onPressed: toggleLike,
                ),
                IconButton(
                  icon: Icon(
                    Icons.mode_comment_outlined,
                    size: 30,
                    color: colors.onSurface,
                  ),
                  onPressed: showCommentsSheet,
                ),
                IconButton(
                  icon: Icon(
                    Icons.send_outlined,
                    size: 30,
                    color: colors.onSurface,
                  ),
                  onPressed:
                      () => Share.share(
                        "Check out this post from ${widget.post.username}!",
                        subject: "Check this out",
                      ),
                ),
              ],
            ),
          ),

          // Caption & Likes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$likeCount likes",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: "${widget.post.username} ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.post.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: showCommentsSheet,
                  child: Text(
                    "View all comments",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Just now",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
