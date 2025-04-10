import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_karo/components/donations/donations_screen.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/screens/ask_ai_screen.dart';
import 'package:sponsor_karo/screens/individual_chat_screen.dart';
import 'package:sponsor_karo/services/chat_service.dart';
import 'package:sponsor_karo/services/follow_service.dart';

class ProfileHeader extends StatefulWidget {
  final PublicProfile publicProfile;
  const ProfileHeader({super.key, required this.publicProfile});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final _chatService = ChatService();
  final _followService = FollowService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isFollowing = false;
  int followers = 0;
  int following = 0;
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    _loadFollowData();
  }

  Future<void> _loadFollowData() async {
    final fetchedFollowers = await _followService.getFollowers(
      widget.publicProfile.username,
    );
    final fetchedFollowing = await _followService.getFollowing(
      widget.publicProfile.username,
    );
    final followingStatus = await _followService.isFollowing(
      widget.publicProfile.username,
    );

    final userEmail = _firebaseAuth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in");
    }
    final username = userEmail.split('@').first.toLowerCase();

    setState(() {
      followers = fetchedFollowers.length;
      following = fetchedFollowing.length;
      isFollowing = followingStatus;
      currentUsername = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        widget.publicProfile.profilePic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn(context, "Posts", "10"),
                        _buildStatColumn(
                          context,
                          "Followers",
                          followers.toString(),
                        ),
                        _buildStatColumn(
                          context,
                          "Following",
                          following.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    widget.publicProfile.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (followers > 20)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.verified, color: Colors.blue, size: 18),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.publicProfile.username,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.publicProfile.bio,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOutlinedButton(
                      context,
                      isFollowing ? "Following" : "Follow",
                      Icons.person_add,
                      () async {
                        if (isFollowing) {
                          await _followService.unfollowUser(
                            widget.publicProfile.username,
                          );
                          setState(() => isFollowing = false);
                          _showSnackBar(
                            context,
                            "Unfollowed successfully",
                            colorScheme,
                          );
                          setState(() {
                            followers--;
                          });
                        } else {
                          await _followService.followUser(
                            widget.publicProfile.username,
                          );
                          setState(() => isFollowing = true);
                          _showSnackBar(
                            context,
                            "Followed successfully",
                            colorScheme,
                          );
                          setState(() {
                            followers++;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPrimaryButton(
                      context,
                      "Sponsor",
                      Icons.attach_money,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DonationScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildOutlinedButton(
                      context,
                      "Message",
                      Icons.message,
                      () {
                        _chatService.createChatWithUid(
                          widget.publicProfile.uid,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => IndividualChatScreen(
                                  user: widget.publicProfile,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AskAIScreen(
                                  username: widget.publicProfile.username,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_money, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Ask AI",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    ColorScheme colorScheme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onPressed,
      child: _buildButtonContent(text, icon),
    );
  }

  Widget _buildOutlinedButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onPressed,
      child: _buildButtonContent(text, icon),
    );
  }

  Widget _buildButtonContent(String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
