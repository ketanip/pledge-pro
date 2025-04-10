import 'package:flutter/material.dart';
import 'package:sponsor_karo/components/analytics/donor_card.dart';
import 'package:sponsor_karo/types.dart';

class TopDonorsPage extends StatefulWidget {
  final List<Donor> allDonors;
  const TopDonorsPage({super.key, required this.allDonors});

  @override
  _TopDonorsPageState createState() => _TopDonorsPageState();
}

class _TopDonorsPageState extends State<TopDonorsPage> {
  late List<Donor> filteredDonors;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDonors = widget.allDonors;
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      final query = searchController.text.toLowerCase();
      filteredDonors =
          widget.allDonors
              .where((donor) => donor.username.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("All Top Donors")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search donors...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child:
                filteredDonors.isEmpty
                    ? Center(
                      child: Text(
                        "No donors found",
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        return DonorCard(donor: filteredDonors[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
