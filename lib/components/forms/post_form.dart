import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sponsor_karo/models/post.dart';
import 'package:sponsor_karo/screens/user_profile.dart';
import 'package:sponsor_karo/services/post_service.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:uuid/uuid.dart';

class CreatePostForm extends StatefulWidget {
  const CreatePostForm({super.key});

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final PostService _postService = PostService();
  final PublicProfileService _profileService = PublicProfileService();

  List<XFile> _pickedImages = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _pickedImages = pickedFiles;
        _currentIndex = 0;
      });
    }
  }

  String? _validateCaption(String? value) {
    return (value == null || value.trim().length < 30)
        ? 'Caption must be at least 30 characters long'
        : null;
  }

  Future<void> _handlePostSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick at least one image.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProfile = await _profileService.getPublicProfile(
        FirebaseAuth.instance.currentUser!.email!
            .split('@')
            .first
            .toLowerCase(),
      );

      final imageFiles =
          _pickedImages.map((xfile) => File(xfile.path)).toList();
      final imageUrls = await _postService.uploadPostImages(
        userProfile.username,
        imageFiles,
      );

      final postId = const Uuid().v4();
      final post = Post(
        id: postId,
        imageUrls: imageUrls,
        caption: _captionController.text.trim(),
        username: userProfile.username,
        likeCount: 0,
      );

      await _postService.createPost(post);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      _captionController.clear();
      setState(() {
        _pickedImages.clear();
        _currentIndex = 0;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(username: userProfile.username),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child:
            _pickedImages.isEmpty ? _buildPlaceholder() : _buildImageCarousel(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: Colors.black54),
          SizedBox(height: 8),
          Text(
            'Tap to pick images',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CarouselSlider.builder(
          itemCount: _pickedImages.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_pickedImages[index].path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
          options: CarouselOptions(
            height: 400,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        Positioned(
          top: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentIndex + 1} of ${_pickedImages.length}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildImagePicker(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _captionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Caption',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        validator: _validateCaption,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handlePostSubmission,
                          icon: const Icon(Icons.post_add),
                          label: const Text('Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
