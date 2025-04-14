import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/core/components/costum_textfield_widget.dart';
import 'package:story_app/provider/add_new/image_picker_provider.dart';
import '../../../core/routes/router.dart';
import '../../core/validator/validator.dart';
import '../../provider/add_new/image_upload_provider.dart';

class AddNewStoryPage extends StatefulWidget {
  final Function onRefresh;

  const AddNewStoryPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<AddNewStoryPage> createState() => _AddNewStoryPageState();
}

class _AddNewStoryPageState extends State<AddNewStoryPage> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _navigateToSelectLocation() async {
    final result = await context.push<LatLng>(Routes.selectLocation);

    if (result != null) {
      setState(() {
        _locationController.text = '${result.latitude}, ${result.longitude}';
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  _onGalleryView();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  _onCameraView();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Story',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 180.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        context.watch<ImagePickerProvider>().imagePath == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 32.0,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Tap to upload image',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: _showImage(),
                              ),
                  ),
                ),
                const SizedBox(height: 24.0),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  keyboardType: TextInputType.multiline,
                  validator: validateDescription,
                  minLines: 1,
                  maxLines: 3,
                  onChanged: (value) => _formKey.currentState?.validate(),
                  borderRadius: BorderRadius.circular(8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                const SizedBox(height: 24.0),
                GestureDetector(
                  onTap: _navigateToSelectLocation,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _locationController,
                      labelText: 'Location',
                      keyboardType: TextInputType.text,
                      validator: validateLocation,
                      minLines: 1,
                      maxLines: 1,
                      borderRadius: BorderRadius.circular(8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _onUpload();
                      }
                    },
                    child: context.watch<ImageUploadProvider>().isUploading
                        ? const SizedBox(
                            height: 30.0,
                            width: 18.0,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Add Story",
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onGalleryView() async {
    final provider = context.read<ImagePickerProvider>();
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<ImagePickerProvider>();
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<ImagePickerProvider>().imagePath;
    return kIsWeb
        ? Image.network(imagePath.toString(), fit: BoxFit.cover)
        : Image.file(File(imagePath.toString()), fit: BoxFit.cover);
  }

  _onUpload() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final imageUploadProvider = context.read<ImageUploadProvider>();
    final imagePickerProvider = context.read<ImagePickerProvider>();
    final imagePath = imagePickerProvider.imagePath;
    final imageFile = imagePickerProvider.imageFile;

    if (imagePath == null || imageFile == null) {
      scaffoldMessengerState.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: const Text("Select an image"),
        ),
      );
      return;
    }

    final description = _descriptionController.text;
    double latitude = 0.0;
    double longitude = 0.0;

    if (_locationController.text.isNotEmpty) {
      final locationParts = _locationController.text.split(", ");
      if (locationParts.length == 2) {
        latitude = double.tryParse(locationParts[0]) ?? 0.0;
        longitude = double.tryParse(locationParts[1]) ?? 0.0;
      }
    }

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();
    final newBytes = await imageUploadProvider.compressImage(bytes);

    await imageUploadProvider.upload(
      newBytes,
      fileName,
      description,
      latitude,
      longitude,
    );

    if (imageUploadProvider.defaultResponse != null) {
      imagePickerProvider.setImageFile(null);
      imagePickerProvider.setImagePath(null);
    }

    scaffoldMessengerState.showSnackBar(
      SnackBar(
        backgroundColor: imageUploadProvider.defaultResponse != null
            ? Colors.green
            // ignore: use_build_context_synchronously
            : Theme.of(context).colorScheme.error,
        content: Text(imageUploadProvider.message),
      ),
    );

    if (imageUploadProvider.defaultResponse != null) {
      widget.onRefresh();
      // ignore: use_build_context_synchronously
      context.pop();
    }
  }
}
