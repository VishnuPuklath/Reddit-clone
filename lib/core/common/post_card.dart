import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

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

    void upvotes(String userId) {
      ref.read(postControllerProvider.notifier).upvotes(post, userId);
    }

    void downvotes(String userId) {
      ref.read(postControllerProvider.notifier).downvotes(post, userId);
    }

    void awardPost(String award, BuildContext context) {
      ref
          .read(postControllerProvider.notifier)
          .awardPost(award: award, context: context, post: post);
    }

    void navigateToUser(BuildContext context) {
      Routemaster.of(context).push('/u/${post.uid}');
    }

    void navigateToCommunity(BuildContext context) {
      Routemaster.of(context).push('/r/${post.communityName}');
    }

    void navigateToComments(BuildContext context) {
      Routemaster.of(context).push('/post/${post.id}/comments');
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
                                  GestureDetector(
                                    onTap: () => navigateToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          post.communityProfilePic),
                                      radius: 16,
                                    ),
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
                                      GestureDetector(
                                        onTap: () => navigateToUser(context),
                                        child: Text(
                                          'u/${post.username}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
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
                                  ),
                                )
                            ],
                          ),
                          if (post.awards.isNotEmpty) ...[
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: post.awards.length,
                              itemBuilder: (context, index) {
                                final award = post.awards[index];
                                return Image.asset(
                                  Constants.awards[award]!,
                                  height: 23,
                                );
                              },
                            )
                          ],
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
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => upvotes(user.uid),
                                    icon: Icon(
                                      Constants.up,
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
                                      onPressed: () => downvotes(user.uid),
                                      icon: Icon(
                                        Constants.down,
                                        color: post.downvotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        navigateToComments(context),
                                    icon: const Icon(
                                      Icons.comment,
                                    ),
                                  ),
                                  Text(
                                    '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  ref
                                      .watch(communityByNameProvider(
                                          post.communityName))
                                      .when(
                                        data: (data) {
                                          if (data.mods.contains(user.uid)) {
                                            IconButton(
                                              onPressed: () =>
                                                  deletePost(context),
                                              icon: const Icon(
                                                Icons.admin_panel_settings,
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                        error: (error, stackTrace) =>
                                            ErrorText(error: error.toString()),
                                        loading: () => const Loader(),
                                      ),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              itemCount: user.awards.length,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 4),
                                              itemBuilder: (context, index) {
                                                final awards =
                                                    user.awards[index];
                                                return GestureDetector(
                                                  onTap: () => awardPost(
                                                      awards, context),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(Constants
                                                        .awards[awards]!),
                                                  ),
                                                );
                                              },
                                            ),
                                          )),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.card_giftcard_outlined))
                                ],
                              )
                            ],
                          ),
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
