import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsor_karo/models/comment.dart';
import 'package:sponsor_karo/screens/user_profile.dart';
import 'package:sponsor_karo/services/comment_service.dart';

class CommentSection extends StatefulWidget {
  final String postId;
  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();

  List<Comment> _comments = [];
  bool _isLoading = true;
  late String currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUserAndLoadData();
  }

  Future<void> getCurrentUserAndLoadData() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      currentUser = userEmail.split('@').first.toLowerCase();
    } else {
      currentUser = "anonymous"; // Fallback in case of error
    }

    final comments = await _commentService.fetchComments(widget.postId);
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  void _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await _commentService.addComment(widget.postId, text);

    _commentController.clear();
    getCurrentUserAndLoadData(); // Refresh comments
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyle = theme.textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colors.onSurface.withAlpha(77),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Text(
                "Comments",
                style: textStyle.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // COMMENT LIST
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text("No comments yet."))
                        : ListView.builder(
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colors.primaryContainer,
                                  child: ClipOval(
                                    child: SvgPicture.network(
                                      'https://api.dicebear.com/9.x/adventurer/svg?seed=${comment.postedBy}',
                                      width: 36,
                                      height: 36,
                                      placeholderBuilder: (context) =>
                                          const CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                                title: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfileScreen(
                                          username: comment.postedBy,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    comment.postedBy,
                                    style: textStyle.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  comment.comment,
                                  style: textStyle.bodySmall,
                                ),
                              );
                            },
                          ),
              ),

              // COMMENT INPUT
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.primaryContainer,
                      child: ClipOval(
                        child: SvgPicture.network(
                          'https://api.dicebear.com/9.x/adventurer/svg?seed=$currentUser',
                          width: 36,
                          height: 36,
                          placeholderBuilder: (context) =>
                              const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Add a comment...",
                          hintStyle: textStyle.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _postComment,
                      child: Text(
                        "Post",
                        style: textStyle.bodyMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
