import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditUserProfile extends ConsumerStatefulWidget {
  final String uid;
  const EditUserProfile({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditUserProfileState();
}

class _EditUserProfileState extends ConsumerState<EditUserProfile> {
  late TextEditingController nameController;
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

  void save() {
    ref.read(userProfileControllerProvider.notifier).editCommunity(
        avatarFile: avatarFile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text.trim());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
      data: (user) {
        return Scaffold(
          backgroundColor: currentTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              TextButton(
                  onPressed: () {},
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
                                : user.banner.isEmpty ||
                                        user.banner == Constants.bannerDefault
                                    ? const Center(
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        ),
                                      )
                                    : Image(image: NetworkImage(user.banner))),
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
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 30,
                              ),
                      ),
                    )
                  ],
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: 'Name', filled: true, border: InputBorder.none),
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
