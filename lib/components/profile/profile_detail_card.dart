import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sponsor_karo/models/detail.dart';

class ProfileDetailCard extends StatelessWidget {
  final Detail detail;

  const ProfileDetailCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Title & Options Menu**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  _getIconForType(detail.type, theme),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (detail.organization != null)
                          Text(
                            detail.organization!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildMoreOptionsMenu(context, theme),
                ],
              ),

              const SizedBox(height: 6),

              // **Timeline & Location**
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(detail.timeline, style: theme.textTheme.bodySmall),
                  if (detail.location != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(detail.location!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),

              const SizedBox(height: 6),

              // **Description**
              Text(detail.description, style: theme.textTheme.bodyMedium),

              const SizedBox(height: 6),

              // **Image Gallery (if available)**
              if (detail.images != null && detail.images!.isNotEmpty)
                _buildImageGallery(context, detail.images!, theme),

              // **Tags as Subtle Text**
              if (detail.tags != null && detail.tags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    detail.tags!.join(" • "),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // **Divider for Separation**
        Divider(
          thickness: 0.5,
          color: theme.dividerColor,
          height: 0,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  // **Icon based on type**
  Widget _getIconForType(String type, ThemeData theme) {
    IconData icon;
    switch (type) {
      case "award":
        icon = Icons.emoji_events;
        break;
      case "work_experience":
        icon = Icons.work;
        break;
      case "education":
        icon = Icons.school;
        break;
      default:
        icon = Icons.info;
    }
    return Icon(icon, size: 24, color: theme.colorScheme.primary);
  }

  // **Three-Dot Menu for Options**
  Widget _buildMoreOptionsMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Edit action selected"),
              backgroundColor: theme.colorScheme.surfaceContainerHighest ,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: theme.colorScheme.surface,
      elevation: 2,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text("Edit"),
                ],
              ),
            ),
          ],
      icon: Icon(
        Icons.more_vert,
        size: 22,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  // **Image Gallery with Zoom**
  Widget _buildImageGallery(
    BuildContext context,
    List<String> images,
    ThemeData theme,
  ) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openImageGallery(context, images, index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // **Open Image Gallery**
  void _openImageGallery(
    BuildContext context,
    List<String> images,
    int startIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  PhotoViewGallery.builder(
                    itemCount: images.length,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(images[index]),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      );
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    pageController: PageController(initialPage: startIndex),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
