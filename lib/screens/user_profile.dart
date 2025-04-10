import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_karo/components/post_card.dart';
import 'package:sponsor_karo/components/profile/all_profile_details.dart';
import 'package:sponsor_karo/components/profile/profile_header.dart';
import 'package:sponsor_karo/components/profile/update_profile_form.dart';
import 'package:sponsor_karo/models/post.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/services/post_service.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;

  const UserProfileScreen({super.key, required this.username});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late PublicProfile _public_profile;
  late List<Post> _userPosts;
  bool _isLoading = true;
  bool _isTabBarVisible = true;
  late String _currentUsername;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _publicProfileService = PublicProfileService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadData();
  }

  void loadData() async {
    try {
      final profile = await _publicProfileService.getPublicProfile(
        widget.username,
      );
      final PostService _postService = PostService();
      final posts = await _postService.getPostByUsername(widget.username);

      final userEmail = _firebaseAuth.currentUser?.email;

      if (userEmail == null) {
        throw Exception("User not logged in");
      }
      final username = userEmail.split('@').first.toLowerCase();

      setState(() {
        _public_profile = profile;
        _userPosts = posts;
        _isLoading = false;
        _currentUsername = username;
      });
    } catch (e) {
      print('Error loading data: $e');
      // Optional: Show error UI here
    }
  }

  void _scrollListener() {
    final shouldHide = _scrollController.offset > 150;
    if (_isTabBarVisible != !shouldHide) {
      setState(() => _isTabBarVisible = !shouldHide);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: colorScheme.surface,
                elevation: 0,
                pinned: true,
                title: Text(
                  widget.username,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                actions:
                    _currentUsername == _public_profile.username
                        ? [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProfileForm(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ]
                        : [],
              ),

              SliverToBoxAdapter(
                child: ProfileHeader(publicProfile: _public_profile),
              ),
              if (_isTabBarVisible)
                SliverPersistentHeader(
                  pinned: false,
                  floating: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      indicatorColor: colorScheme.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8),
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on, size: 18)),
                        Tab(icon: Icon(Icons.info_outline, size: 18)),
                      ],
                    ),
                  ),
                ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts Tab
            _userPosts.isEmpty
                ? Center(child: Text("No posts yet"))
                : ListView.builder(
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: _userPosts.length,
                  itemBuilder:
                      (context, index) => PostCard(post: _userPosts[index]),
                ),

            // Details Tab
            ProfileDetailsScreen(details: _public_profile.details, username: _public_profile.username,),
          ],
        ),
      ),
    );
  }
}

// Compact Sliver Tab Bar (Theme-Aware)
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => 36;
  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

// Full List Page (Theme-Aware)
class FullListScreen extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const FullListScreen({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title, style: theme.textTheme.titleMedium)),
      body: ListView(children: items),
    );
  }
}
