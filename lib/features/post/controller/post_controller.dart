import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
      postRepository: ref.read(postRepositoryProvider),
      ref: ref,
      storageRepository: ref.read(storageRepositoryProvider));
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
    state = false;
    res.fold(
        (l) => showSnackBar(text: l.message, context: context),
        (r) => {
              showSnackBar(text: 'Posted Successfully', context: context),
              Routemaster.of(context).pop()
            });

    void shareLinkPost(
        {required BuildContext context,
        required String title,
        required Community selectedCommunity,
        required String link}) async {
      state = true;
      String postId = const Uuid().v1();
      final user = _ref.read(userProvider)!;
      Post post = Post(
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
        state = false;
        res.fold(
            (l) => showSnackBar(text: l.message, context: context),
            (r) => {
                  showSnackBar(text: 'Posted Successfully', context: context),
                  Routemaster.of(context).pop()
                });
      });
    }
  }
}
