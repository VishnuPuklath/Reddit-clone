import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isTypeImage = post.type == 'image';
    final isTypeLink = post.type == 'link';
    final isTypeText = post.type == 'text';
    final user = ref.watch(userProvider)!;

    void deletePost(BuildContext context) {
      ref.read(postControllerProvider.notifier).deletePost(post, context);
    }

    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                            .copyWith(right: 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
                                    radius: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(children: [
                                      Text(
                                        'r/${post.communityName}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'u/${post.username}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              if (post.uid == user.uid)
                                IconButton(
                                    onPressed: () => deletePost(context),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ))
                            ],
                          ),
                          Text(
                            post.title,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          if (isTypeImage)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image(
                                image: NetworkImage(post.link!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: post.link!),
                            ),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Constants.up,
                                  size: 30,
                                  color: post.upvotes.contains(user.uid)
                                      ? Pallete.redColor
                                      : null,
                                ),
                              ),
                              Text(
                                '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                style: const TextStyle(fontSize: 17),
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Constants.down,
                                    size: 30,
                                    color: post.upvotes.contains(user.uid)
                                        ? Pallete.blueColor
                                        : null,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.comment,
                                  size: 30,
                                ),
                              ),
                              Text(
                                '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                style: const TextStyle(fontSize: 17),
                              ),
                            ],
                          )
                        ]),
                  )
                ],
              ),
            )
          ]),
        )
      ],
    );
  }
}
