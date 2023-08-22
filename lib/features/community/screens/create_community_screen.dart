import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    communityNameController.dispose();
  }

  final communityNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create a Community'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          const Align(
              alignment: Alignment.centerLeft, child: Text('Community name')),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: communityNameController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(18),
                filled: true,
                hintText: 'r/Community_name',
                border: InputBorder.none),
            maxLength: 21,
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              child: const Text(
                'Create community',
                style: TextStyle(fontSize: 16),
              ))
        ]),
      ),
    );
  }
}
