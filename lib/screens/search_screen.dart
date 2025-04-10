import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/screens/user_profile.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final _publicProfileServices = PublicProfileService();

  late List<PublicProfile> _allUsers;
  List<PublicProfile> _filteredUsers = [];

  bool _showFilters = false;
  bool _athletesOnly = false;
  bool _verifiedOnly = false;
  bool _isLoading = true;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();

    _searchController.addListener(() {
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    final publicProfiles = await _publicProfileServices.getAllPublicProfiles();
    setState(() {
      _allUsers = publicProfiles;
      _isLoading = false;
      _filterUsers();
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterUsers();
    });
  }

  void _onFilterChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterUsers();
    });
  }

  void _filterUsers() {
    final searchText = _searchController.text.toLowerCase();

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchesSearch = user.username.toLowerCase().contains(searchText) ||
            user.fullName.toLowerCase().contains(searchText);

        final matchesAthlete = !_athletesOnly || user.details.length > 1;
        final matchesVerified = !_verifiedOnly || user.followerCount > 20;

        return matchesSearch && matchesAthlete && matchesVerified;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search users...",
                          prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: const Icon(Icons.filter_alt_sharp),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              if (_showFilters)
                Column(
                  children: [
                    SwitchListTile(
                      title: Text("Athletes Only", style: theme.textTheme.bodyMedium),
                      value: _athletesOnly,
                      onChanged: (value) {
                        setState(() {
                          _athletesOnly = value;
                        });
                        _onFilterChanged();
                      },
                    ),
                    SwitchListTile(
                      title: Text("Verified Only", style: theme.textTheme.bodyMedium),
                      value: _verifiedOnly,
                      onChanged: (value) {
                        setState(() {
                          _verifiedOnly = value;
                        });
                        _onFilterChanged();
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              Expanded(
                child: _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          "No users found",
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(user.profilePic),
                            ),
                            title: Text(user.fullName, style: theme.textTheme.bodyLarge),
                            subtitle: Text(
                              user.bio.length > 30
                                  ? "${user.bio.substring(0, 30)}..."
                                  : user.bio,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                            trailing: user.followerCount > 20
                                ? const Icon(Icons.verified, color: Colors.blue, size: 18)
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileScreen(username: user.username),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
  }
}
