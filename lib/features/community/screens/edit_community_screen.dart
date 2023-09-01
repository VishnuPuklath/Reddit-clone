import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  EditCommunityScreen({
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? avatarFile;
  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectavatarImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatarFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        avatarFile: avatarFile,
        bannerFile: bannerFile,
        context: context,
        community: community);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(communityByNameProvider(widget.name)).when(
      data: (community) {
        return Scaffold(
          backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Edit community'),
            actions: [
              TextButton(
                  onPressed: () => save(community),
                  child: const Text(
                    'save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => selectBannerImage(),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: Pallete
                            .darkModeAppTheme.textTheme.bodyText2!.color!,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 150,
                            child: bannerFile != null
                                ? Image.file(
                                    bannerFile!,
                                    fit: BoxFit.cover,
                                  )
                                : community.banner.isEmpty ||
                                        community.banner ==
                                            Constants.bannerDefault
                                    ? const Center(
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        ),
                                      )
                                    : Image(
                                        image: NetworkImage(community.banner))),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => selectavatarImage(),
                        child: avatarFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(avatarFile!),
                                radius: 30,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                                radius: 30,
                              ),
                      ),
                    )
                  ],
                ),
              )
            ]),
          ),
        );
      },
      error: (error, stackTrace) {
        return ErrorText(error: error.toString());
      },
      loading: () {
        return const Loader();
      },
    );
  }
}
