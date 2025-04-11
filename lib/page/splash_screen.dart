import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: _buildTitle(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      "Storygram",
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }
}