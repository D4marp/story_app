import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/core/theme/theme.dart';
import 'package:story_app/core/theme/utils.dart';
import 'package:story_app/data/preferences/token.dart';
import 'package:story_app/provider/add_new/image_picker_provider.dart';
import 'package:story_app/provider/auth/login_provider.dart';
import 'package:story_app/provider/auth/register_provider.dart';
import 'package:story_app/provider/detail/stories_detail_provider.dart';
import 'package:story_app/provider/home/stories_provider.dart';
import 'core/routes/router.dart';
import 'data/api/api_service.dart';
import 'provider/add_new/image_upload_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<TokenPreference>(
          create: (_) => TokenPreference(),
        ),
        ChangeNotifierProvider<LoginProvider>(
          create: (context) => LoginProvider(
            context.read<ApiService>(),
            context.read<TokenPreference>(),
          ),
        ),
        ChangeNotifierProvider<RegisterProvider>(
          create: (context) => RegisterProvider(
            context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<StoriesProvider>(
          create: (context) => StoriesProvider(
            context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<StoryDetailProvider>(
          create: (context) => StoryDetailProvider(
            context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<ImagePickerProvider>(
          create: (_) => ImagePickerProvider(),
        ),
        ChangeNotifierProvider<ImageUploadProvider>(
          create: (_) => ImageUploadProvider(
            ApiService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Roboto", "Roboto");
    final appTheme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: 'Story App',
      theme: appTheme.light(),
      routerConfig: router,
    );
  }
}
