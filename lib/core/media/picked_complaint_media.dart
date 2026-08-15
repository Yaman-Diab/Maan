// -------------------------
// Picked Complaint Media
// -------------------------

/// صورة أو فيديو مرفق بشكوى — بعكس [PickedImage] (صورة بروفايل/وثيقة)،
/// بلا قصّ ولا ضغط بايتات بالذاكرة: أدلّة الشكوى بترفع كما التُقطت،
/// وملفات الفيديو أكبر من ما يصحّ نحمّله كامل بالرام.
///
/// الرفع عبر [path] مباشرة (`MultipartFile.fromFile`) — الملف مؤقّت
/// وبيضل موجود لحد ما يخلص الإرسال، نفس فرضية [PickedImage.path].
final class PickedComplaintMedia {
  final String path;
  final String fileName;
  final int sizeInBytes;
  final bool isVideo;

  const PickedComplaintMedia({
    required this.path,
    required this.fileName,
    required this.sizeInBytes,
    required this.isVideo,
  });
}
