import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sponsor_karo/components/profile/profile_detail_card.dart';
import 'package:sponsor_karo/components/profile/profile_details_form.dart';
import 'package:sponsor_karo/models/detail.dart';
import 'package:sponsor_karo/state/user_provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final List<Detail> details;
  final String username;

  const ProfileDetailsScreen({
    super.key,
    required this.details,
    required this.username,
  });

  @override
  _ProfileDetailsScreenState createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final Map<String, bool> _expandedSections = {};
  late String _currentUsername;
  

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) return;

    setState(() {
      _currentUsername = user.username;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupedDetails = _groupDetailsByType();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Add More" Button (Always present, but content is conditional)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 10, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _currentUsername == widget.username
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailForm(),
                            ),
                          );
                        }
                        : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      _currentUsername == widget.username
                          ? const [
                            Icon(Icons.add),
                            SizedBox(width: 6),
                            Text("Add more"),
                          ]
                          : const [Text("View Profile Details")],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...groupedDetails.entries.map((entry) {
            final sectionTitle = _getHeaderTitle(entry.key);
            final items = entry.value;
            final isExpanded = _expandedSections[entry.key] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    color: colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Text(
                      sectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: colorScheme.outlineVariant,
                ),

                // Items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount:
                      isExpanded
                          ? items.length
                          : (items.length > 3 ? 3 : items.length),
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return ProfileDetailCard(detail: items[index]);
                  },
                ),

                // View More / Less
                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _expandedSections[entry.key] = !isExpanded;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isExpanded ? "View Less" : "View More",
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Map<String, List<Detail>> _groupDetailsByType() {
    Map<String, List<Detail>> groupedDetails = {};
    for (var detail in widget.details) {
      groupedDetails.putIfAbsent(detail.detailType, () => []).add(detail);
    }
    return groupedDetails;
  }

  String _getHeaderTitle(String type) {
    switch (type) {
      case "awards":
        return "🏆 Awards & Achievements";
      case "work_experience":
        return "💼 Work Experience";
      case "education":
        return "🎓 Education";
      case "competitions":
        return "🏅 Competitions";
      case "goals":
        return "🎯 Goals";
      default:
        return _formatTypeName(type);
    }
  }

  String _formatTypeName(String rawType) {
    return rawType
        .replaceAll("_", " ")
        .split(" ")
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(" ");
  }
}
