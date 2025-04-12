import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/enum/state.dart';
import 'package:story_app/data/model/request_add_story_model.dart';
import 'package:story_app/provider/story_add_provider.dart';
import 'package:story_app/routes/page_manager.dart';
import 'package:story_app/util/helper.dart';
import 'package:story_app/widget/safe_area.dart';

class AddStoryPage extends StatefulWidget {
  final VoidCallback onSuccessAddStory;

  const AddStoryPage({super.key, required this.onSuccessAddStory});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: AppBar(
        title: const Text("Add Story"),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<AddStoryProvider>(
        create: (context) => AddStoryProvider(ApiService()),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _selectImage(),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to select image",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description!';
                    }
                    return null;
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Description",
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AddStoryProvider>(
                  builder: (context, provider, _) {
                    switch (provider.state) {
                      case ResultState.hasData:
                        print(provider.message);
                        afterBuildWidgetCallback(() {
                          context.read<PageManager>().returnData(true);
                          widget.onSuccessAddStory();
                        });
                        break;
                      case ResultState.error:
                      case ResultState.noData:
                        print(provider.message);
                        break;
                      default:
                        break;
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _onUploadPressed(provider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        child: const Text("Upload"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onUploadPressed(AddStoryProvider provider) {
    if (_formKey.currentState?.validate() == true && _selectedImage != null) {
      AddStoryRequest request = AddStoryRequest(
        description: _descriptionController.text,
        photo: _selectedImage!,
      );
      provider.addStory(request);
    }
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedImage =
                      await imagePicker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedImage =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
