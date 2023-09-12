import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  String type;
  AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  File? bannerFile;
  List<Community> communities = [];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  Community? selectedCommunity;
  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isTypeImage = widget.type == 'image';
    final isTypeLink = widget.type == 'link';
    final isTypeText = widget.type == 'text';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Post ${widget.type}'),
        actions: [TextButton(onPressed: () {}, child: const Text('Share'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextField(
            maxLength: 30,
            controller: titleController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(18),
                hintText: 'Enter title here',
                filled: true,
                border: InputBorder.none),
          ),
          const SizedBox(
            height: 10,
          ),
          if (isTypeImage)
            GestureDetector(
              onTap: () => selectBannerImage(),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [10, 4],
                strokeCap: StrokeCap.round,
                color: currentTheme.textTheme.bodyText2!.color!,
                child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    height: 150,
                    child: bannerFile != null
                        ? Image.file(
                            bannerFile!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                            ),
                          )),
              ),
            ),
          if (isTypeText)
            TextField(
              maxLines: 5,
              controller: descriptionController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(18),
                  hintText: 'Enter description here',
                  filled: true,
                  border: InputBorder.none),
            ),
          if (isTypeLink)
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(18),
                  hintText: 'Enter link here',
                  filled: true,
                  border: InputBorder.none),
            ),
          const SizedBox(
            height: 20,
          ),
          const Align(
              alignment: Alignment.topLeft, child: Text('Select Community')),
          ref.watch(userCommunitiesProvider).when(
                data: (data) {
                  communities = data;
                  if (data.isEmpty) {
                    return const SizedBox();
                  }
                  return DropdownButton(
                    value: selectedCommunity ?? data[0],
                    items: data
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e.name)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCommunity = value;
                      });
                    },
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              )
        ]),
      ),
    );
  }
}
