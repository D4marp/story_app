import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/ui/home/widget/image_stories.dart';

import '../../../core/components/avatar_name_widget.dart';
import '../../../core/routes/router.dart';
import '../../../data/model/response/stories/list_stories.dart';

class StoryCard extends StatelessWidget {
  final ListStory story;
  final void Function(String) onTap;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('${Routes.detailStory}/${story.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(156, 190, 188, 188),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: ImageStory(
                imageUrl: story.photoUrl ?? '',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarName(
                    name: story.name ?? '',
                  ),
                  const SizedBox(height: 8),
                  if (story.description != null)
                    Text(
                      story.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
