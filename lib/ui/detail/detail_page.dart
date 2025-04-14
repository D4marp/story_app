import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/core/components/massage_widget.dart';
import 'package:story_app/provider/detail/stories_detail_provider.dart';
import 'package:story_app/ui/detail/widget/body_of_detail.dart';
import 'package:story_app/ui/detail/widget/shimmer_detail.dart';
import '../../core/static/stories_detail.dart';

class DetailPage extends StatefulWidget {
  final String id;

  const DetailPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<StoryDetailProvider>().getStoryDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Story',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<StoryDetailProvider>(
        builder: (context, value, child) {
          return switch (value.resultState) {
            StoryDetailLoadingState() => const Center(
                child: ShimmerStoryDetail(),
              ),
            StoryDetailLoadedState(data: var storyDetail) =>
              storyDetail.story != null
                  ? BodyOfDetail(data: storyDetail.story!)
                  : const Center(
                      child: Message(
                        title: 'Oops! Something went wrong',
                        subtitle: 'Story data is missing.',
                      ),
                    ),
            StoryDetailErrorState() => const Center(
                child: Message(
                  title: 'Oops! Something went wrong',
                  subtitle: 'Please check your internet connection.',
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
