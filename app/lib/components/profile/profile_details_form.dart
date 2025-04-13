import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sponsor_karo/models/detail.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:uuid/uuid.dart';

class ProfileDetailForm extends StatefulWidget {
  const ProfileDetailForm({super.key});

  @override
  _ProfileDetailFormState createState() => _ProfileDetailFormState();
}

class _ProfileDetailFormState extends State<ProfileDetailForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  String? selectedDetailType;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timelineController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController detailTypeController = TextEditingController();
  final _profileService = PublicProfileService();

  List<XFile>? pickedImages = [];

  // Detail Type Options
  final List<String> detailTypes = [
    'Work Experience',
    'Competitions',
    'Goals',
    'Awards',
    'Others',
  ];

  final Uuid _uuid = const Uuid();

  Future<List<String>> _uploadImages(String username) async {
    if (pickedImages == null || pickedImages!.isEmpty) return [];

    List<String> imageUrls = [];
    for (XFile image in pickedImages!) {
      final url = await _profileService.uploadProfileImage(
        username,
        File(image.path),
      );
      imageUrls.add(url);
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Detail Form',
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detail Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedDetailType,
                decoration: InputDecoration(
                  labelText: 'Detail Type',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                items:
                    detailTypes.map((detailType) {
                      return DropdownMenuItem(
                        value: detailType,
                        child: Text(
                          detailType,
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDetailType = value;
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a detail type'
                            : null,
              ),
              SizedBox(height: 16),

              _buildTextField('Title', titleController),
              SizedBox(height: 16),
              _buildTextField(
                'Description',
                descriptionController,
                maxLines: 4,
              ),
              SizedBox(height: 16),
              _buildTextField('Timeline', timelineController),
              SizedBox(height: 16),
              _buildTextField('Organization', organizationController),
              SizedBox(height: 16),
              _buildTextField('Location', locationController),
              SizedBox(height: 16),

              if (selectedDetailType == 'Others') ...[
                _buildTextField('Detail Type (Other)', detailTypeController),
                SizedBox(height: 16),
              ],

              // Pick Images
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final pickedFiles = await _picker.pickMultiImage();
                    setState(() {
                      pickedImages = pickedFiles;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: theme.textTheme.labelLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      Text('Pick Images', style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              if (pickedImages != null && pickedImages!.isNotEmpty)
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        pickedImages!.asMap().entries.map((entry) {
                          int index = entry.key;
                          XFile image = entry.value;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(image.path),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: -10,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      pickedImages!.removeAt(index);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Processing...',
                            style: theme.textTheme.bodyMedium,
                          ),
                          backgroundColor: colorScheme.primary,
                        ),
                      );

                      try {
                        // Get current profile to fetch username
                        final userProfile = await _profileService
                            .getPublicProfile(
                              FirebaseAuth.instance.currentUser!.email!
                                  .split('@')
                                  .first
                                  .toLowerCase(),
                            );

                        // Upload images
                        final imageUrls = await _uploadImages(
                          userProfile.username,
                        );

                        // Create detail
                        final detail = Detail(
                          id: _uuid.v4(),
                          type: selectedDetailType!,
                          title: titleController.text.trim(),
                          images: imageUrls,
                          description: descriptionController.text.trim(),
                          timeline: timelineController.text.trim(),
                          organization:
                              organizationController.text.trim().isNotEmpty
                                  ? organizationController.text.trim()
                                  : null,
                          location:
                              locationController.text.trim().isNotEmpty
                                  ? locationController.text.trim()
                                  : null,
                          tags: [],
                          detailType:
                              selectedDetailType == 'Others'
                                  ? detailTypeController.text.trim()
                                  : selectedDetailType!,
                        );

                        await _profileService.addDetailToProfile(
                          userProfile.username,
                          detail,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Detail added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(
                          context,
                        ).pop(); // Optionally close the form
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    textStyle: theme.textTheme.labelLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignLabelWithHint: true, // Aligns label text with hint text
        contentPadding: const EdgeInsets.only(top: 12, left: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter ${label.toLowerCase()}';
        }
        return null;
      },
    );
  }
}
