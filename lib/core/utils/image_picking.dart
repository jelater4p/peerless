// Görsel seçme (galeri/kamera), kırpma ve yüklemeden önce sıkıştırma.
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n.dart';
import '../theme/app_theme.dart';

/// Galeri mi kamera mı? (iptal = null)
Future<ImageSource?> askImageSource(BuildContext context) {
  final l = context.l10n;
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.image),
            title: Text(l.pickFromGallery),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(LucideIcons.camera),
            title: Text(l.takePhoto),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
        ],
      ),
    ),
  );
}

/// Profil fotoğrafı (kare, yuvarlak kırpma, 512px) veya kapak (3:1, 1500px).
Future<Uint8List?> pickCroppedImage(
  BuildContext context, {
  required bool avatar,
}) async {
  final source = await askImageSource(context);
  if (source == null || !context.mounted) return null;
  final picked = await ImagePicker().pickImage(source: source);
  if (picked == null || !context.mounted) return null;

  final c = context.colors;
  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: avatar ? const CropAspectRatio(ratioX: 1, ratioY: 1) : const CropAspectRatio(ratioX: 3, ratioY: 1),
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: avatar ? context.l10n.cropAvatar : context.l10n.cropCover,
        toolbarColor: c.bg,
        toolbarWidgetColor: c.ink,
        statusBarLight: c.brightness == Brightness.light,
        backgroundColor: c.bg,
        activeControlsWidgetColor: c.accent,
        cropStyle: avatar ? CropStyle.circle : CropStyle.rectangle,
        lockAspectRatio: true,
        hideBottomControls: false,
      ),
    ],
  );
  if (cropped == null) return null;
  final size = avatar ? 512 : 1500;
  return FlutterImageCompress.compressWithFile(
    cropped.path,
    minWidth: size,
    minHeight: avatar ? size : size ~/ 3,
    quality: 85,
    format: CompressFormat.jpeg,
  );
}

/// İçerik görseli: kırpma yok, uzun kenar ~1600px, JPEG.
Future<Uint8List?> pickPostImage(BuildContext context) async {
  final source = await askImageSource(context);
  if (source == null) return null;
  final picked = await ImagePicker().pickImage(source: source);
  if (picked == null) return null;
  return FlutterImageCompress.compressWithFile(
    picked.path,
    minWidth: 1600,
    minHeight: 1600,
    quality: 82,
    format: CompressFormat.jpeg,
  );
}
