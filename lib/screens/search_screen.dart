import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sponsor_karo/screens/user_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _showFilters = false;
  bool _athletesOnly = false;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    // Mock API request (replace with real API)
    final response = await http.get(Uri.parse('https://dummyjson.com/users'));
    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body)['users'];
      setState(() {
        _allUsers =
            users.map((user) {
              return {
                "id": user["id"],
                "username": user["username"],
                "name": user["firstName"] + " " + user["lastName"],
                "bio": user["company"]["title"],
                "profilePic":
                    "https://api.dicebear.com/7.x/identicon/svg?seed=${user["height"]}",
                "verified": user["eyeColor"] == "Green", // Mock verified status
                "athlete": user["age"] < 30, // Mock athlete status
              };
            }).toList();
        _filteredUsers = _allUsers;
      });
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers =
          _allUsers.where((user) {
            final matchesSearch =
                user["username"].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                user["name"].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

            final matchesAthlete = !_athletesOnly || user["athlete"];
            final matchesVerified = !_verifiedOnly || user["verified"];

            return matchesSearch && matchesAthlete && matchesVerified;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.iconTheme.color,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onChanged: (value) => _filterUsers(),
                ),
              ),

              SizedBox(width: 8),

              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(Icons.filter_alt_sharp),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Filters (Only show when _showFilters is true)
        if (_showFilters)
          Column(
            children: [
              SwitchListTile(
                title: Text("Athletes Only", style: theme.textTheme.bodyMedium),
                value: _athletesOnly,
                onChanged: (value) {
                  setState(() {
                    _athletesOnly = value;
                    _filterUsers();
                  });
                },
              ),
              SwitchListTile(
                title: Text("Verified Only", style: theme.textTheme.bodyMedium),
                value: _verifiedOnly,
                onChanged: (value) {
                  setState(() {
                    _verifiedOnly = value;
                    _filterUsers();
                  });
                },
              ),
            ],
          ),
        const SizedBox(height: 10),

        // User List
        Expanded(
          child:
              _filteredUsers.isEmpty
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
                          backgroundImage: NetworkImage(
                            'https://api.dicebear.com/7.x/identicon/png?seed=${user['profilePic']}',
                          ),
                        ),

                        title: Text(
                          user["name"],
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          "${user["bio"].length > 30 ? user["bio"].substring(0, 30) + "..." : user["bio"]}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        trailing:
                            user["verified"]
                                ? Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                )
                                : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UserProfileScreen(
                                    username: user["username"],
                                  ),
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
