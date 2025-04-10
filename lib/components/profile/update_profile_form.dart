import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsor_karo/screens/user_profile.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:sponsor_karo/models/public_profile.dart';

class UpdateProfileForm extends StatefulWidget {
  const UpdateProfileForm({super.key});

  @override
  _UpdateProfileFormState createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _image;

  final PublicProfileService _profileService = PublicProfileService();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final username = user.email!.split('@').first.toLowerCase();
      final profile = await _profileService.getPublicProfile(username);

      setState(() {
        _nameController.text = profile.fullName;
        _bioController.text = profile.bio;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
      });
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No user logged in')));
        return;
      }

      final username = user.email!.split('@').first.toLowerCase();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        final profile = await _profileService.getPublicProfile(username);

        String updatedProfilePic = profile.profilePic;
        if (_image != null) {
          updatedProfilePic = await _profileService.uploadProfileImage(
            username,
            _image!,
          );
        }

        final updatedProfile = PublicProfile(
          uid: profile.uid,
          username: profile.username,
          fullName: _nameController.text.trim(),
          profilePic: updatedProfilePic,
          bio: _bioController.text.trim(),
          details: profile.details,
          followerCount: profile.followerCount,
          followingCount: profile.followingCount,
        );

        await _profileService.updatePublicProfile(updatedProfile);

        Navigator.of(context).pop(); // Dismiss loader

        // Navigate using pushReplacement with dynamic username
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(username: username),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Dismiss loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating profile: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Update Profile")),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            child:
                                _image == null
                                    ? Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: colorScheme.onSurface,
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                          labelStyle: theme.textTheme.bodyLarge,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _bioController,
                        maxLength: 150,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Bio",
                          border: OutlineInputBorder(),
                          labelStyle: theme.textTheme.bodyLarge,
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.only(
                            top: 20,
                            left: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your bio";
                          }
                          return null;
                        },
                      ),
                      Text("The bio will be used to generate personality for your AI chatbot."),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            textStyle: theme.textTheme.labelLarge,
                          ),
                          child: Text("Update Profile"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
