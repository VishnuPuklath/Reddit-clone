import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/comment_model.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
      postRepository: ref.read(postRepositoryProvider),
      ref: ref,
      storageRepository: ref.read(storageRepositoryProvider));
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.read(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

//stream provider for post by id
final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  return ref.read(postControllerProvider.notifier).getPostById(postId);
});
//stream provider for comments by post id
final getPostsCommentsProvider = StreamProvider.family((ref, String postId) {
  return ref.read(postControllerProvider.notifier).getCommentsOfPost(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    Post post = Post(
        title: title,
        id: postId,
        description: description,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: []);

    final res = await _postRepository.post(post);
    _ref
        .read(postControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold(
        (l) => showSnackBar(text: l.message, context: context),
        (r) => {
              showSnackBar(text: 'Posted Successfully', context: context),
              Routemaster.of(context).pop()
            });
  }

  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    Post post = Post(
        title: title,
        link: link,
        id: postId,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: []);

    final res = await _postRepository.post(post);
    _ref
        .read(postControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold(
        (l) => showSnackBar(text: l.message, context: context),
        (r) => {
              showSnackBar(text: 'Posted Successfully', context: context),
              Routemaster.of(context).pop()
            });
  }

  void shareImagePost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required File? file}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imageRes.fold((l) => Failure(l.message), (r) async {
      Post post = Post(
          title: title,
          link: r,
          id: postId,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'image',
          createdAt: DateTime.now(),
          awards: []);

      final res = await _postRepository.post(post);
      _ref
          .read(postControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold(
          (l) => showSnackBar(text: l.message, context: context),
          (r) => {
                showSnackBar(text: 'Posted Successfully', context: context),
                Routemaster.of(context).pop()
              });
    });
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _ref.read(postRepositoryProvider).deletePost(post);
    _ref
        .read(postControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold(
      (l) => showSnackBar(context: context, text: l.message),
      (r) => showSnackBar(context: context, text: 'Post deleted successfully'),
    );
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _ref.read(postRepositoryProvider).fetchUserPosts(communities);
    } else {
      return Stream.value([]);
    }
  }

  void upvotes(Post post, String userId) async {
    _ref.read(postRepositoryProvider).upvotes(post, userId);
  }

  void downvotes(Post post, String userId) async {
    _ref.read(postRepositoryProvider).downvotes(post, userId);
  }

  Stream<Post> getPostById(String id) {
    return _postRepository.getPostById(id);
  }

  void addComment(String text, BuildContext context, String postId) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
        id: commentId,
        createdAt: DateTime.now(),
        postId: postId,
        profilePic: user.profilePic,
        text: text,
        username: user.name);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(postControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold(
        (l) => showSnackBar(context: context, text: l.message), (r) => null);
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _postRepository.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  void awardPost(
      {required Post post,
      required String award,
      required BuildContext context}) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);
    res.fold((l) => showSnackBar(context: context, text: l.message), (r) {
      _ref
          .read(postControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
