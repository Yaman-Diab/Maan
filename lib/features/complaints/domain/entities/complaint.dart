// -------------------------
// Complaint
// -------------------------

import 'package:equatable/equatable.dart';

import 'complaint_category.dart';
import 'complaint_status.dart';
import 'complaint_type.dart';

/// شكوى مقدَّمة — مواطن (فردية/جماعية) أو بلاغ طارئ.
///
/// ✅ **شكل القراءة مؤكّد أخيراً بأمثلة استجابة حقيقية** — `id`/`type`/
/// `title`/`status` كانت مؤكّدة أصلاً (نفس حقول الإرسال). التصنيف
/// والموقع يوصلوا الآن ككائنين متداخلين (`category: {id,name}` و
/// `location`/`pin: {latitude,longitude}`) لا حقول مسطّحة — راجع
/// `ComplaintModel.fromMap`. الوسائط أصبحت روابط حقيقية (`mediaUrls`)
/// بدل عدّاد/علم بوجودها بس.
///
/// ⚠️ عدّاد التصويت (`votes`/`hasVoted`) **لسه بلا عقد مؤكّد** — كل
/// الأمثلة الحقيقية الواصلة كانت لشكاوى المستخدم نفسه (صفر أصوات
/// منطقياً)، فما وصل مثال بعد يثبت اسم الحقل الحقيقي لو كان مختلفاً عن
/// التخمين الحالي.
final class Complaint extends Equatable {
  final int id;
  final ComplaintType type;
  final ComplaintCategory? category;
  final ComplaintStatus status;
  final String title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final int votes;
  final bool hasVoted;
  final List<String> mediaUrls;
  final DateTime? createdAt;

  /// شكواي أنا لا شكوى مواطن ثاني — من التاب المفتوح وقت الطلب، مش من
  /// حقل بالاستجابة.
  final bool isMine;

  const Complaint({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    this.category,
    this.description,
    this.latitude,
    this.longitude,
    this.votes = 0,
    this.hasVoted = false,
    this.mediaUrls = const [],
    this.createdAt,
    this.isMine = false,
  });

  bool get hasMedia => mediaUrls.isNotEmpty;

  /// الطارئة والجماعية أوزانهما أعلى بترتيب «الأولوية» — نفس معادلة
  /// التصميم الأصلي، بانتظار تأكيد معادلة الباك اند الحقيقية لو اختلفت.
  int get priorityWeight {
    final typeBoost = switch (type) {
      ComplaintType.emergency => 400,
      ComplaintType.collective => 60,
      ComplaintType.individual => 0,
    };

    return votes + typeBoost;
  }

  Complaint copyWith({int? votes, bool? hasVoted}) {
    return Complaint(
      id: id,
      type: type,
      category: category,
      status: status,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      votes: votes ?? this.votes,
      hasVoted: hasVoted ?? this.hasVoted,
      mediaUrls: mediaUrls,
      createdAt: createdAt,
      isMine: isMine,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    category,
    status,
    title,
    description,
    latitude,
    longitude,
    votes,
    hasVoted,
    mediaUrls,
    createdAt,
    isMine,
  ];
}
