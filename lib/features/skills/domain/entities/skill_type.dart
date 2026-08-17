// -------------------------
// Skill Type
// -------------------------

/// نوع المهارة — عشرة قيم بالضبط، مؤكّدة من `App\Enums\SkillType` الحقيقي
/// (مصدر الباك اند مباشرة، لا تخمين).
enum SkillType {
  technical('technical'),
  craftsmanship('craftsmanship'),
  construction('construction'),
  social('social'),
  educational('educational'),
  medical('medical'),
  driving('driving'),
  logistics('logistics'),
  environmental('environmental'),
  other('other');

  const SkillType(this.wireValue);

  final String wireValue;

  static SkillType? fromApi(String? value) {
    for (final type in SkillType.values) {
      if (type.wireValue == value) return type;
    }

    return null;
  }
}
