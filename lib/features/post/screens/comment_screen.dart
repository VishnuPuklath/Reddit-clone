import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widgets/comment_card.dart';
import 'package:reddit_clone/models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;

  CommentScreen({required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref
        .read(postControllerProvider.notifier)
        .addComment(commentController.text, context, post.id);
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    onSubmitted: (value) => addComment(data),
                    controller: commentController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        hintText: 'What is your thoughts'),
                  ),
                  ref.watch(getPostsCommentsProvider(data.id)).when(
                      data: (data) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final comment = data[index];
                              return CommentCard(comment: comment);
                            },
                          ),
                        );
                      },
                      error: (error, stackTrace) {
                        print(error);
                        return ErrorText(error: error.toString());
                      },
                      loading: () => const Loader())
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
