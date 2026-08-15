// -------------------------
// Complaint
// -------------------------

import 'package:equatable/equatable.dart';

import 'complaint_category.dart';
import 'complaint_status.dart';
import 'complaint_type.dart';

/// شكوى مقدَّمة — مواطن (فردية/جماعية) أو بلاغ طارئ.
///
/// ⚠️ **شكل استجابة القراءة (`GET /api/complains/...`) غير مؤكّد** —
/// Postman collection عندها أمثلة الإرسال بس (بلا مثال استجابة).
/// الحقول الأساسية (`id`, `type`, `category_id`, `title`, `status`)
/// مؤكّدة لأنها نفس حقول الإرسال؛ الباقي (`votes`, `hasVoted`,
/// `mediaCount`) تخمين موثّق حسب اصطلاح Laravel الشائع — راجع
/// `ComplaintModel.fromMap` لنقطة التصحيح.
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
  final bool hasMedia;
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
    this.hasMedia = false,
    this.createdAt,
    this.isMine = false,
  });

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
      hasMedia: hasMedia,
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
    hasMedia,
    createdAt,
    isMine,
  ];
}
