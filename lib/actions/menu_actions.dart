import 'package:flutter/material.dart';
import 'package:sketchspace/components/settings_popup.dart';

class OpenMenuIntent extends Intent {
  final BuildContext context;
  const OpenMenuIntent(this.context);
}

class CloseMenuIntent extends Intent {
  const CloseMenuIntent();
}

// Action definitions

class OpenMenuAction extends Action<OpenMenuIntent> {
  OpenMenuAction();

  @override
  void invoke(covariant OpenMenuIntent intent) {
    showDialog(context: intent.context,
      builder: (BuildContext dialogContext) => const SettingsPopup());
  }
}