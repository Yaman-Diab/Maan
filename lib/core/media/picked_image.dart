// -------------------------
// Picked Image
// -------------------------

import 'dart:typed_data';

/// صورة عدّت خط الأنابيب كاملاً: اختيار ← قص ← ضغط.
///
/// بتحمل الاثنين عن قصد:
/// * [path] للعرض الفوري بـ`Image.file` — أرخص من `MemoryImage` لأن
///   Flutter بيخبّي الملف، وبيخلّي مقارنة الحالة على نص بدل مصفوفة بايت.
/// * [bytes] للرفع — الملف مؤقّت وممكن ينمسح، فما منعتمد عليه بالشبكة.
final class PickedImage {
  final String path;
  final Uint8List bytes;
  final String fileName;

  const PickedImage({
    required this.path,
    required this.bytes,
    required this.fileName,
  });

  int get sizeInBytes => bytes.length;
}
