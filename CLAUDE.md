# maan — دليل المعمارية

تطبيق تجارة إلكترونية بـ Flutter، عربي أولاً مع دعم إنجليزي عبر `easy_localization`.
المعمارية **Clean Architecture** مع تنظيم feature-first، و`flutter_bloc` كنمط حالة موحّد.

## قواعد الطبقات

```
lib/
├── core/                 بنية تحتية مشتركة — ما بتستورد شي من features/
└── features/<feature>/
    ├── <feature>_injection.dart    تسجيل اعتماديات الميزة
    ├── domain/                     منطق العمل — Dart نقي فقط
    │   ├── entities/               كيانات Equatable، بلا مفاتيح JSON
    │   ├── repositories/           عقود abstract بترجّع Result<T>
    │   └── usecases/               تنسيق خطوة عمل واحدة
    ├── data/                       تنفيذ العقود
    │   ├── datasources/            المكان الوحيد اللي بيعرف Dio والـ endpoints
    │   ├── models/                 DTOs مع fromMap/toMap + toEntity()
    │   └── repositories/           *Impl بتمسك الاستثناء وبترجّع Result
    └── presentation/<screen>/
        ├── cubit/                  <screen>_cubit.dart + <screen>_state.dart
        ├── pages/
        └── widgets/
```

**اتجاه الاعتماد**: `presentation → domain ← data`. الـ domain ما بتستورد
`package:flutter` ولا `package:dio` ولا أي شي من `core/network`.

## قواعد ثابتة

| القاعدة | التفصيل |
|---|---|
| **Cubit لا Bloc** | كل الشاشات نماذج request/response. Bloc بس لو في حاجة حقيقية لـ event semantics (debounce، pagination). |
| **الحالة بتحمل بياناتها** | `State` كلاس Equatable بحقول + `copyWith`. ممنوع marker classes مع حقول عامة على الـ Cubit. |
| **الـ Cubit بلا Flutter** | `TextEditingController` و`FocusNode` و`GlobalKey<FormState>` بتضل بالـ `State` تبع الصفحة؛ الـ Cubit بيحمل القيم كنصوص عبر `onChanged`. |
| **`Result<T>` لا استثناءات** | الـ repositories والـ use cases بترجّع `Ok<T>` أو `Err<T>` — راجع `core/result/result.dart`. |
| **`Failure` لا `ApiException`** | التحويل بيصير مرة وحدة بـ `*RepositoryImpl` عبر `FailureMapper.fromError`. رسائل الخطأ مصدرها `ApiErrorMessages` — لا تكتب رسائل جديدة بالـ mapper. |
| **DI يدوي** | GetIt بدون codegen. كل ميزة بتسجّل حالها، و`main.dart` هي نقطة التركيب. |
| **Cubits factory، الباقي lazySingleton** | كل دخول لشاشة بده Cubit بحالة نظيفة. |

## إضافة ميزة جديدة

1. `features/<name>/domain/` — الكيان، ثم عقد الـ repository، ثم الـ use cases.
2. `features/<name>/data/` — DTOs، datasource، ثم `*RepositoryImpl` مع
   `try/catch` بيرجّع `Err(FailureMapper.fromError(error))`.
3. `features/<name>/presentation/<screen>/` — Cubit + State، وصفحة بـ
   `BlocProvider(create: (_) => sl<XCubit>())` و`BlocConsumer`.
4. `features/<name>/<name>_injection.dart` — سجّل الواجهات لا التنفيذات:
   `sl.registerLazySingleton<XRepository>(() => XRepositoryImpl(sl()))`.
5. ناد `register<Name>Dependencies(sl)` من `main.dart`.
6. أضف الـ endpoints لـ `core/network/api_endpoints.dart` **حسب
   `collection.md`** — هو عقد الباك اند المعتمد. المسارات تحت `/api`
   مباشرة (بلا `v1`)، ومفاتيح الأجسام snake_case.

المرجع الكامل: ميزة `login` — من `domain/usecases/login_usecase.dart`
لحد `presentation/login/pages/login_page.dart`.

## الثيم

```
core/design_system/
├── app_palette.dart          القيم الخام (hex) — ممنوع استخدامها بالـ widgets
├── app_semantic_colors.dart  ThemeExtension: توكنات حسب الدور + light/dark
├── app_text_styles.dart      ThemeExtension: الأنماط، بتنبنى بالـ .sp
├── app_theme.dart            light() و dark() + ColorScheme كاملة
└── app_theme_context.dart    context.colors · context.texts · context.scheme
```

| القاعدة | التفصيل |
|---|---|
| **ممنوع لون يدوي** | لا `Color(0x...)` ولا `Colors.*` بالـ widgets. استخدم `context.colors` أو `context.scheme`. |
| **ممنوع نمط نص ثابت** | `context.texts.f16W500Black` — لا ثوابت `static`، لأنها بتجمّد `.sp`. |
| **التسمية حسب الدور** | `textPrimary` لا `black`. الاسم الفيزيائي بيصير كذبة بالوضع الداكن. |
| **`AppTheme` جوّا `ScreenUtilInit`** | بتستخدم `.sp`؛ بناؤها برّا بيحسب القياسات على مقاس غلط. |
| **توكن جديد؟** | ضيفه لـ`AppSemanticColors` بنسختَي light و dark + `copyWith` + `lerp`. |

**تفضيلات العرض**: `SettingsCubit` (singleton) بيحمل `themeMode` و`textScale`،
وبيتخزّنوا بـ`SharedPreferences` عبر `SettingsStorageService` — منفصلين عن
`SecureStorageService` لأنهم غير حساسين.

**حجم الخط**: `_TextScaleScope` بـ`main.dart` بيضرب تفضيل المستخدم
بإعداد النظام (ما بيستبدله) وبيحدّه بـ1.6 حتى ما ينكسر التخطيط.

**شاشة الإعدادات**: `features/settings/presentation/pages/settings_page.dart`
— بلا `domain`/`data`، لأنها كلها عرض/تفاعل مع أشياء موجودة أصلاً
(`SettingsCubit`، `AppSessionController`، `AppPermissionService`).
المسار `/profile/settings` (فرعي عن `profile`، `context.push` من أيقونة
الترس بشريط `ProfilePage` — بتظهر للزائر كمان لأن الثيم/اللغة/حجم الخط
مفيدة قبل الدخول). الأقسام: المظهر (ثيم + حجم خط، عبر `SettingsCubit`
الموجود)، اللغة (`context.setLocale` من `easy_localization` مباشرة —
بلا cubit، لأن الحزمة نفسها بتخزّن وبترجع التفضيل عبر `saveLocale`)،
الخصوصية (روابط `openAppSettings()` بس — راجع الملاحظة تحت)، حول
التطبيق (رقم الإصدار عبر `package_info_plus`، الباقي روابط "قريباً")،
والحساب (خروج مؤكَّد بورقة، حذف حساب — راجع فجوة تحت).

⚠️ **بلا فحص صلاحيات حي عمداً**: أضفنا `permission_handler` **بس**
لـ`openAppSettings()` (فتح إعدادات النظام)، مش لفحص `Permission.x.status`.
السبب: خط أنابيب الصور الحالي (`image_picker`) بيعتمد على تفويض عبر
Intent بأندرويد (`ACTION_IMAGE_CAPTURE`/photo picker)، مش أذونات وقت
تشغيل مباشرة — فحص حالة ساذج كان رح يعرض "غير مسموح" حتى لو خط الأنابيب
شغّال فعلياً. `AppPermissionService` (`core/permissions/`) بالتالي
عندها بس `openSystemSettings()`.

⚠️ **`_SettingsControlRow` (بالصفحة نفسها)**: صف «تسمية + عنصر تحكّم»
(الثيم/حجم الخط/اللغة) — `Flexible` **حول التسمية بس**، مش حول
الطرفين متل `AppSectionHeader`. لو حطينا `Flexible` عالاثنين، Flutter
بيقسم المساحة 50/50 بغض النظر عن الحاجة الفعلية، فبينكسر عنصر التحكّم
(شرائح متعددة أعرض من نصف الصف). القاعدة: العنصر التفاعلي ياخد حجمه
كامل دائماً، والتسمية تنقطع بـ ellipsis لو لزم — لا العكس.

⚠️ **فجوة**: حذف الحساب بالشاشة **بلا endpoint حقيقي** — الورقة
والتأكيد جاهزين، بس التنفيذ بيعرض رسالة "غير متاح حالياً" بدل طلب
فعلي. نقطة التصحيح الوحيدة `SettingsPage._deleteAccount`.

**اختبارات `EasyLocalization` بملفات مستقلة عمداً**
(`test/features/settings/settings_page_test.dart` +
`settings_page_guest_test.dart`): تأكّدنا تجريبياً إن ماونت ثانٍ لودجت
`EasyLocalization` **داخل نفس ملف الاختبار** بيرجّع شجرة ودجتات فاضية
تماماً بلا أي استثناء ظاهر (على الأغلب حالة سباق داخلية بكاش تحميل
الترجمة عبر عمليات pump متتالية بنفس الـ isolate). الحل: ماونت واحد بس
لكل ملف — سيناريوهات الجلسة المسجّلة تنفّذ **تسلسلياً** جوّا اختبار
`testWidgets` وحيد، وسيناريو الزائر (يحتاج حالة أولية مختلفة) بملف
منفصل حتى ياخد الماونت الأول الموثوق تبع عملية الاختبار (كل ملف بياخد
isolate مستقل بـ`flutter test`). أي شاشة جديدة محتاجة `context.locale`/
`context.setLocale` (لا `.tr()` وحدها) بده تتبع نفس النمط.

## تاريخ الميلاد — مصدر واحد

شاشتان بتستخدموه (التسجيل وتعديل الهوية)، فكل شي مشترك انتقل لـ`core`:

| الملف | المسؤولية |
|---|---|
| `core/domain/birth_date.dart` | الكيان + قواعد التحقق + **قيم العجلات** (`initialDay`, `selectableYears`, `clampDay`, `maxSelectableDay`) كدوال ثابتة نقية |
| `core/design_system/birth_date_error_message.dart` | ترجمة `BirthDateError` لرسالة عرض |
| `core/design_system/widgets/birth_date_fields.dart` | الحقول الثلاثة + فتح العجلات |

`BirthDate` بـ`core/domain/` مش بـ`features/auth/` لنفس سبب `AccountStatus`:
صار عابراً للميزات لما احتاجته `profile.updateIdentity`.

⚠️ **الودجت بتاخد الأجزاء الثلاثة كقيم لا حالة شاشة** — لأن كل شاشة
`State` تبعها نوع مختلف. أي منطق تاريخ جديد مكانه `BirthDate` لا
الـ`State`، وإلا بينكرر مرتين من جديد.

## عجلة الاختيار (`number_picker_sheet`)

الخروج **بلا زر** بيقبل القيمة فقط إذا تحرّكت العجلة فعلاً؛ وإلا ما
بيغيّر شي. قاعدة وحدة بتخدم الحالتين: حقل فيه قيمة وما تحرّكت العجلة →
«لا تغيير» = نفس القيمة؛ وحقل فاضي → بيضل فاضي بدل ما نخترع له تاريخاً.

⚠️ **ثلاث إيماءات خروج، مسارَين مختلفين بـFlutter**:
* نقرة برّا + رجوع النظام → `Navigator.maybePop` → بيمسكها `PopScope`.
* سحب الورقة للأسفل → `BottomSheet.onClosing` بينادي `Navigator.pop`
  المباشر بلا قيمة، **فبيتجاوز `PopScope`**.

لهيك القيمة الحالية بتتتبّع بمتغيّر **برّا** الورقة (`movedTo`) لا بحالتها
— حالة الورقة بتنهدم قبل ما نقدر نقرأها بحالة السحب. تعديل هالملف بلا
الانتباه لهالفرق بيرجّع باگ «السحب بيلغي بينما النقر بيقبل».

## حدود طول الحقول

`CustomTextFormField.maxLength` (وبيتمرّر عبر `PasswordTextFormField`)
بيمنع الكتابة/اللصق بعد الحد مباشرة عبر `LengthLimitingTextInputFormatter`
— لا رسالة تحقّق بعد الإدخال، ولا عدّاد أحرف مرسوم (`counterText: ''`):
التصميم ما فيه هالعنصر.

| الحد | القيمة | ليش |
|---|---|---|
| `AppValidators.emailMaxLength` | 254 | الحد الفعلي حسب RFC 5321 |
| `AppValidators.passwordMaxLength` | 64 | bcrypt بيقصّ عند 72 بايت بصمت (ثغرة معروفة لا مجرد سعة) |
| `AppValidators.nameMaxLength` | 50 | أطول اسم حقيقي موثّق ~35 حرف |
| `AppValidators.nationalIdMaxLength` | 12 | أطول رقم وطني بالمنطقة |

⚠️ **كلمة مرور تسجيل الدخول بلا `maxLength` عمداً** — عكس كل حقول كلمة
المرور التانية. هاي كلمة مرور **موجودة أصلاً** بحساب، ممكن اتنشأت قبل
أي سياسة حالية؛ حدّها بيقفل صاحبها برّا حسابه نهائياً لو كانت أطول من
64. نفس منطق فصل `loginPasswordValidator` عن `passwordValidator`.

## التحميل الهيكلي (`skeletonizer`)

بس للتحميل **الأول** لمحتوى حقيقي من الشبكة (بطاقات/نصوص غنية) — لا
للفورمات (المستخدم عم يعبّي، مش بينتظر محتوى)، ولا لأزرار الإرسال
(سبينر محلي صغير كافٍ)، ولا للشاشات اللي بتحمّل محلياً بلا شبكة
(الإعدادات). الاستخدامان الحاليان: [profile_skeleton.dart](lib/features/profile/presentation/profile/widgets/profile_skeleton.dart)
و[verification_skeleton.dart](lib/features/verification/presentation/verification/widgets/verification_skeleton.dart)
— كلاهما بيستبدلوا `state.isFirstLoad` / `VerificationView.loading` مباشرة،
لا سحب-للتحديث (`RefreshIndicator` بيضل يعرض المحتوى القديم لحد ما يوصل
الجديد، نفس ما كان قبل).

**أسلوبان حسب تعقيد الودجت الحقيقي**:
* **`ProfileSkeleton`** — بتغلّف `ProfileContent` الحقيقي ببيانات
  `CitizenProfile` وهمية عبر `Skeletonizer(child: ProfileContent(...))`.
  هيك أي تعديل مستقبلي على شكل الشاشة بينعكس تلقائياً بلا صيانة إضافية.
  القيم الوهمية إنجليزية قصيرة (`'Name'`/`'Surname'`) — الطول هو المهم
  للعظمة لا المحتوى، والنص أصلاً مغطّى بالكامل. الحقول اللي بترجع
  `null` بالتصميم الحقيقي (رقم وطني، تاريخ ميلاد) بتاخد قيمة وهمية غير
  فاضية عمداً — لو تركناها `null` كانت هتعرض «—» (حرف وحيد) فيطلع عظم
  بعرض غريب بدل شريط واقعي.
* **`VerificationSkeleton`** — تخطيط عام يدوي بـ`Bone`/`AppCard`، **مش**
  تغليف `VerificationFormView` الحقيقي. السبب: هاد محتاج
  `TextEditingController` حي وcallbacks لاختيار صور، وخانة الرفع الفاضية
  عندها إطار منقّط مرسوم بـ`CustomPaint` ما بينحوّل لعظمة مفهومة —
  تلفيق حالة/متحكّمات وهمية لودجت تفاعلي بهالتعقيد أعقد من الفايدة.
  تنازل واعٍ عن الدقّة البصرية (تعديل شكل النموذج الحقيقي ما بينعكس
  هون تلقائياً) مقابل بساطة الصيانة.

⚠️ **لون الوميض من التوكنات لا افتراضي الحزمة**: `ShimmerEffect(baseColor:
colors.fieldDisabledBackground, highlightColor: colors.fieldBackground)`
بكل استخدام — نفس قاعدة «ممنوع لون يدوي»، والافتراضي الرمادي الفاتح
تبع الحزمة ما بينلائم الوضع الداكن تلقائياً.

⚠️ **الأداء**: الودجت بينبنى **بس** جوّا شرط التحميل الأول (`if
(state.isFirstLoad) return ...`)، مش دائم بالشجرة مع تبديل `enabled` —
صفر تكلفة بعد وصول البيانات الحقيقية لأنه بينهدم تماماً. `ignorePointers`
افتراضي الحزمة `true`، فما في حاجة لتعطيل الأزرار الوهمية يدوياً.

⚠️ **اختبار الحزمة بـ`find.byType` ما بيشتغل**: `Skeletonizer` و`Bone`
عوامّ (`factory`) بيرجّعوا أصنافاً خاصة فعلياً (`_Skeletonizer`/`_Bone`)،
فـ`find.byType(Skeletonizer)` أو `find.byType(Bone)` بيرجّعوا صفر
نتائج دايماً (`runtimeType` مختلف عن النوع المطلوب) — تأكّدنا تجريبياً.
الاختبارات بتفحص عبر ودجتات عامة حقيقية (`ProfileContent`, `AppCard`)
وغياب استثناء بدل نوع الحزمة الداخلي. وكمان: **لا `pumpAndSettle`** مع
أي ودجت فيه `Skeletonizer` مفعّل — تأثير الوميض حركة لانهائية، نفس مشكلة
مؤشّر التقدّم الدوّار.

## الترجمة

`easy_localization` مع `assets/translations/{en,ar}.json` — 189 مفتاح بالملفين.

| القاعدة | التفصيل |
|---|---|
| **ممنوع نص ظاهر ثابت** | لا إنجليزي ولا **عربي** مكتوب بالكود. كل نص عبر `'key'.tr()`. |
| **مفاتيح نصية مباشرة** | لا ثوابت `AppStrings` ولا codegen — الحماية من الأخطاء المطبعية من `test/localization/localization_test.dart`. |
| **snake_case** | `verify_email_button` لا `verifyEmailButton`. مسطّحة بلا تعشيش. |
| **الوسائط بالاسم** | `'code_length_error'.tr(namedArgs: {'length': '6'})` — لا دمج نصوص، لأن ترتيب الكلمات بيختلف بالعربي. |
| **رسائل الشبكة** | `ApiErrorMessages` هي المصدر الوحيد؛ بترجّع `.tr()` فبتتبع لغة التطبيق. |

**اتساق المصطلحات العربية** (مفروض باختبار): `تسجيل الدخول` · `إنشاء حساب` ·
`إلغاء` · `تأكيد`، وكل حالات التحميل بصيغة `جارٍ ...`.

الاختبار بيفحص: تطابق المفاتيح بين اللغتين · المفاتيح الناقصة · **غير
المستخدمة** · المكررة · القيم الفاضية · تطابق `{args}` · علامة `؟` العربية ·
وجود أي نص عربي ثابت بـ`lib/`.

⚠️ **الاختبارات بتفحص المفتاح لا النص**: `.tr()` بترجّع المفتاح نفسه لما
تكون الترجمة غير مهيّأة، فـ`expect(failure.message, 'error_connection')`
مقصودة وبتخلّي الاختبارات مستقلة عن اللغة.

⚠️ **الماسح بيقرأ التعليقات كمان**: بيدوّر على المفتاح الحرفي قبل نقطة
الترجمة بكل سطر بلا استثناء، فذكر النمط داخل تعليق بيسجّل «مفتاح مستخدم»
اسمه `key` وبيوقّع الاختبار. ولنفس السبب المفتاح لازم يكون **نصاً حرفياً**
لا متغيّراً — لو احتجت اختيار بين مفاتيح، مرّر دالة ترجمة لا اسم مفتاح
(راجع `ProfileContent._count`).

## الاختبار

```
flutter test        # 466 اختبار
flutter analyze     # صفر ملاحظات
```

- **Use cases**: `mocktail` لعمل mock لعقود الـ repositories.
- **Cubits**: `bloc_test` للتأكد من تسلسل الحالات.
- **Repository impls**: `HttpClientAdapter` مزيّف للتأكد من شكل الطلب
  ومن تحويل الأخطاء — راجع `test/features/auth/data/auth_repository_impl_test.dart`.
- **DI**: `test/di/service_locator_test.dart` بيتأكد إن كل الرسم بينحلّ.
- **الثيم**: الاختبارات بتثبّت كل توكن على قيمته الأصلية (ضد الارتداد
  البصري)، وبتتأكد إن `.sp` بتكبر مع الشاشة بدل ما تتجمّد، وبتفحص تباين
  WCAG بالوضعين. لازم تنبني جوّا `ScreenUtilInit` — راجع
  `test/core/design_system/app_text_styles_test.dart`.

## حالة الهجرة

كل ميزة `auth` مهاجَرة: ما ضل ولا `ChangeNotifier` controller بالمشروع،
وكل الـ endpoints مربوطة حسب `collection.md` (المرجع المعتمد للباك اند).

| الشاشة | الـ endpoint |
|---|---|
| `login` | `POST /api/auth/login` |
| `sign_up` | `POST /api/auth/register` |
| `verify_email` | `POST /api/auth/checkCode` + `POST /api/email/verification-notification` |
| `forgot_password` | `POST /api/auth/forgetPassword` |
| `verify_reset_code` | `POST /api/auth/checkCode` + `POST /api/auth/forgetPassword` (إعادة إرسال) |
| `create_new_password` | `POST /api/auth/resetPassword` |
| `profile` | `GET /api/profile` + `POST /api/profile/update` |
| `edit_identity` | `POST /api/profile/update` (نفس مسار الصورة) |
| `verification` | `GET /api/verification` + `POST /api/verification/store` + `POST /api/verification/update` (تصحيح) |

**مظروف الاستجابة** ⚠️: الـ backend بيرجّع **الفشل بـ HTTP 200** والحالة
الحقيقية بالجسم (`status: 0` أو `success: false`). `ApiEnvelope` بيكشفها
داخل `ApiClient`، فما في ميثود بتحتاج تفحص بنفسها. الكشف **صريح فقط** —
`"status": "active"` (حقل خدمة) ما بينحسب فشلاً.

**حالة الحساب**: `AccountStatus` بـ`core/session/` مش بـ`features/auth/`،
لأنها اهتمام صلاحيات عابر للميزات (شكاوى، طابور، تصويت). مصدرها الوحيد
`AppSessionController.accountStatusChanged` مهما تغيّر مصدر البيانات.
أي قيمة مجهولة بتنعامل كـ**أقل صلاحية**.

**حراسة المسارات**: `AppRedirect.verifiedOnlyRoutes` — فاضية اليوم لأن
`home` و`profile` متاحتان للزائر. عند إضافة شاشة خدمة، ضيف مسارها للقائمة
وبتشتغل الحراسة تلقائياً.

**شاشة البداية**: `features/splash/presentation/` — عرض بحت بلا domain ولا
data. ما بتقرّر متى تنتهي: `AppSessionController.bootstrap()` بيقلب
`isInitialized` فيشتغل `AppRedirect` وينقل المستخدم. الحركات من ثلاثة
`AnimationController` (حلقات 3s · نقاط 1.2s · دخول لمرة وحدة)، وكل عنصر
متكرر بياخد نفس المنحنى بإزاحة زمنية بدل متحكّم لكل واحد.

**الملف الشخصي**: `features/profile/` — أول ميزة غير `auth` بالمشروع.
`GET /api/profile` بيرجّع **نفس كائن المستخدم** تبع استجابة الدخول، فالميزة
بتعيد استخدام `AuthUser` و`AuthUserModel` من `features/auth/` بدل نسخة
ثانية بنفس الحقول. استيراد بين ميزتين مقبول هون لأنه كيان domain نقي؛ لو
ظهر مستهلك ثالث، بينتقل لـ`core/session/` متل `AccountStatus`.

الشاشة كمان **أحدث مصدر لحالة الحساب**: `ProfileCubit` بينادي
`accountStatusChanged` عند كل تحميل ناجح، لأن التوثيق ممكن يكون اعتُمد بعد
آخر تسجيل دخول.

⚠️ **الزائر ما بيضرب الـ endpoint**: `ProfilePage` بتفحص `isLoggedIn` قبل
ما تبني الـ Cubit. بلا هالحارس، فتح التاب كزائر بيرجّع 401 فـ
`AuthInterceptor` بيفهمها «انتهت الجلسة» وبيسجّل خروج.

**`ImageSourceSheet` بـ`core/design_system/widgets/`** — كانت
`AvatarSourceSheet` بميزة profile، انتقلت لـ`core` لما احتاجتها شاشة
التوثيق بنفس البنية حرفياً. الفرق الوحيد بين الاستخدامين نص العنوان
فصار وسيطاً. ⚠️ **كل النصوص بتوصلها مترجَمة من مكان الاستدعاء لا
كمفاتيح**: ودجت بـ`core` ما بيعرف مفاتيح ميزة، وماسح الترجمة بيتطلّب
المفتاح يكون نصاً حرفياً قبل `.tr()` مباشرة.

**`AppCard`/`AppSectionHeader` بـ`core/design_system/widgets/`** — كانوا
`ProfileCard`/`ProfileSectionHeader` بهالميزة، انتقلوا لـ`core` لما
احتاجتهم شاشة الإعدادات كمان (نفس سبب `BirthDate`/`AppValidators`: ودجت
عرض بحت بلا اعتماديّة domain، مستهلَك من ميزتين). أي widget جديد
بمواصفات مشابهة (بلا حالة، بلا استيراد من `domain/` الميزة) وبيبان
احتمال استخدامه بميزة تانية — انقله لـ`core` **قبل** ما يتكرّر، مش بعد.

**«الشهادات والمهارات»**: بانر مصمَت بلون الهوية بأسفل بطاقة الهوية —
دائماً ظاهر، بعكس بانر التوثيق (شرطي بحالة الحساب). المسار
`AppRoutes.certificatesAndSkills` (`/profile/certificates-skills`) لسه
⏳ **بيوصل لـ`_TempPage` المؤقّتة** لا شاشة حقيقية — الهدف حالياً بس
تجهيز نقطة الدخول والانتقال لحد ما تُبنى الشاشة الفعلية. نمط جاهز
لأي مدخل مستقبلي مشابه (زر/بانر بمسار حقيقي بس شاشة لسه ما جهزت):
`GoRoute` بـ`app_router.dart` بيرجّع `_TempPage(title: ..., description:
'coming_soon'.tr())` بدل هدر وقت ببناء placeholder جديد كل مرة.

**الصورة الشخصية**: خط أنابيب من أربع خطوات —
`image_picker` ← `image_cropper` ← `flutter_image_compress` ← رفع.
أول ثلاثة بـ`core/media/ImagePickerService` (عام عن قصد: مرفقات الشكاوى
وصور التوثيق رح تستخدمه)، والرابعة بطبقة data تبع الميزة. الخدمة بلا
`BuildContext`: ألوان شاشة القص بتنمرّر كـ`CropperAppearance` من الواجهة.

الناتج مربّع 512px بجودة 85 وبلا EXIF (بيانات الموقع ما بترتفع مع صورة
عامة). `ProfileState.localAvatarPath` بيخلّي الصورة تبيّن **قبل** رد
السيرفر، وبينمسح لو فشل الرفع — عرض صورة السيرفر ما استلمها كذبة.

⚠️ **إعدادات منصّة مطلوبة** (معمولة، بس لا تنحذف): `UCropActivity`
معلَنة بـ`AndroidManifest.xml` — بلاها بينهار التطبيق **وقت التشغيل** لا
وقت البناء. و`NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription`
بـ`ios/Runner/Info.plist`، وبلاهم بترفض آبل التطبيق بالمراجعة.

**401 عند تسجيل الدخول معناه بيانات خاطئة، لا جلسة منتهية**: `FailureMapper`
العام بيترجم أي 401 لرسالة «سجّل دخولك من جديد» — صحيح لـ endpoint محمي
فقد توكنه، غلط تماماً لمحاولة دخول أصلاً ما إلها جلسة. الباك اند الحقيقي
بيرجّع 401 بلا حقل `code` (بس `message` نصّي)، فمسار التصنيف حسب الكود
القديم ما كان يشتغل أبداً مع هالباك اند. `AuthRepositoryImpl.login`
بيمسك `ApiException` صراحة قبل `FailureMapper` ويحوّل 401 لـ
`AuthFailure('error_invalid_credentials')` مباشرة — تمييز خاص بمعرفة
endpoint الدخول، مش شي `FailureMapper` المشترك يقدر يعرفه (401 بمكان
تاني بالتطبيق لسه لازم يعني جلسة منتهية).

**`POST /api/auth/refresh` — عقد مؤكّد أخيراً (`TokenRefreshService`)**:
طراز `tymon/jwt-auth` كما توقّعنا — توكن JWT واحد بيتجدّد بإعادة إرسال
**نفس التوكن الحالي** عبر هيدر `Authorization`، بلا `refresh_token`
منفصل بالجسم ولا جسم إرسال أصلاً. أربع استجابات حقيقية موثّقة (لوغ
فعلي) أكّدت هذا وكشفت باگ حقيقي: `ApiAuthPolicy.publicEndpoints` كانت
تشمل `refresh`، فـ`AuthInterceptor.onRequest` ما كان يرفق الهيدر أبداً
— **هيك بالضبط كان الباك اند يرجع "Token not provided"**. الإصلاح:
شيل `refresh` من `publicEndpoints` (بيضل إله معاملة خاصة عبر
`isRefreshEndpoint` لمنع حلقة إعادة المحاولة، مش عبر "عام").

⚠️ **الرد الفاشل `{"status":1,"message":"Token not provided","data":null}`
له `status:1` رغم إنه فشل** — `ApiEnvelope` القياسية (محافظة عمداً على
الفحص الصريح) ما بتلتقطها. `TokenRefreshService` ما بيعتمد عليها بمفردها:
أي رد بلا `data.token` صريح بيترفض بغض النظر عن `status`. راجع تعليق
الملف للأشكال الثلاثة الموثّقة الباقية (`Wrong number of segments`،
`Could not decode token`).

**`TokenPair`/`access`/`refresh` بـ`ApiResponseKeys` كانت dead code** —
نموذج access/refresh زوج ما إله وجود بهالباك اند من الأساس (log الدخول
الحقيقي فيه `token` واحد بس). انشالت مع الإصلاح فوق، وكذا
`SecureStorageService.saveRefreshToken`/`getRefreshToken`/`saveTokens`/
`hasRefreshToken` ومفتاح `SecureStorageKeys.refreshToken` — كل التخزين
الآن بتوكن وحيد (`accessToken`) يعبّر عن الجلسة كلها.

**توثيق الهوية** (`features/verification/`): مكتملة — `domain` و`data`
و`presentation/verification/`. المسار
`POST /api/verification/store` مؤكّد من الباك اند مع مثال استجابة حقيقي
(`national_id` + `images[]`). العدد **صورتين بالضبط لا حد أدنى** —
رسالة الباك اند الحقيقية "must contain 2 items" يعني قاعدة `size:2`،
مش `min:2`. كيان `VerificationRequest` منفصل عن `AccountStatus`: الأول
حالة الطلب نفسه (`pending`/`approved`/`rejected` — الثلاث مؤكّدة بالكامل
من enum الباك اند الحقيقي `App\Enums\VerificationStatus`)، والثاني حالة
الحساب العامة اللي بيغيّرها الباك اند بعد المراجعة (`visitor`/`verified`/
`closed` — كمان مؤكّدة بالكامل من `App\Enums\AccountStatus`؛ لا يوجد
حالة "بانتظار التحقق" منفصلة على مستوى الحساب — راجع تعليق `AccountStatus`
بـ`core/session/`).

**تعديل طلب قائم**: `POST /api/verification/update` — تصحيح رقم وطني
غلط بطلب لسه `pending`، مؤكّد مع مثال استجابة حقيقي (نفس شكل `store`
بالضبط). ⚠️ الجسم مؤكّد **جزئياً**: `id` (معرّف الطلب) + `national_id`
بس — **الصور مش جزء من هالطلب**. ما في مسار مؤكّد لتصحيح صورة غلط
بطلب قائم؛ نقطة التصحيح الوحيدة لو تأكّد لاحقاً:
`VerificationRemoteDataSource.update`.

⚠️ **صور التوثيق مش صورة بروفايل** — الشاشة بتستخدم
`ImagePickerService.pickDocument` لا `pickAvatar`: التانية بتقصّ **دائرة
مقفولة 1:1 بـ512px** مصمّمة لأفاتار، والقصّ الدائري بياكل زوايا بطاقة
الهوية — يعني بالضبط المعلومات اللي الطلب قائم عليها. `pickDocument`
بتقصّ مستطيل حر بـ1600px وجودة 92 (النص المطبوع لازم ينقرأ من قِبَل
موظّف البلدية) ومع أدوات التدوير ظاهرة (صور البطاقات بتطلع مقلوبة كتير).

**الرقم الوطني — مالك واحد**: شاشة التوثيق **وحدها** بتحرّره. انشال
حقله من `edit_identity` (اللي بيضل مسؤول عن الاسم وتاريخ الميلاد بس)،
لأن رقماً بينعدّل من شاشتين بيخلق تناقضاً: الموظّف بيراجع صوراً مربوطة
برقم ممكن يكون اتغيّر بعد إرسالها.

⚠️ **القيمة بتضل تُرسَل مع `POST /api/profile/update`** رغم غياب الحقل —
الجسم واحد، وإسقاط الحقل خطر (ممكن الباك اند يقرأ غيابه كـ«امسحه» متل
حقل الصورة الفاضي). `EditIdentityState.nationalId` بيحملها بلا
`nationalIdChanged`.

⚠️ **وبالتالي `nationalId` انشال من `EditIdentityState.canSubmit`** —
المستخدم غير الموثّق ما عنده رقم أصلاً (`null`)، فلو ضل شرطاً بيصير هو
بالضبط اللي **ما بيقدر** يعدّل اسمه أو تاريخ ميلاده.

**بطاقة «البيانات الشخصية»** بأعلى نموذج التوثيق: **عرض فقط** (اسم +
تاريخ ميلاد) مع زر «تعديل» بينقل لـ`editIdentity`. سببها الشرط الثالث
بالتنبيه — «يجب أن تطابق المعلومات هويتك الرسمية» — فالمستخدم لازم يشوف
شو رح ينبعت قبل ما يرسل. `VerificationCubit` بيقرأ `GetProfileUseCase`
**بالتوازي** مع حالة الطلب؛ فشلها بيخفي البطاقة بس وما بيوقّع الشاشة.

**شاشة التوثيق** (`presentation/verification/`): **شاشة واحدة بأربعة
عروض** لا أربع شاشات — النموذج · قيد المراجعة · مرفوض · معتمد. العرض
بيتحدّد من حالة الطلب اللي بترجع من `GET /api/verification` وقت الفتح،
مش من ملاحة المستخدم: هو دايماً بيوصل من نفس المدخل (بانر «وثّق حسابك»
بالملف الشخصي) وبيشوف وين صار طلبه.

✅ **شكل `GET /api/verification` مؤكّد أخيراً بمثال حقيقي**: `{"data":[{...}]}`
— قائمة طلبات كاملة تحت `data`، كل طلب فيه `user` مضمّن كامل (نفس شكل
`AuthUser`) ومصفوفة `rejections` (فاضية بمثالنا، الطلب لسه `pending`).
`VerificationRequestModel.listFromResponse` بتضل تقبل الأشكال الدفاعية
التانية (قائمة مباشرة، كائن مفرد، `data.data`) بلا كلفة إضافية، بس
الشكل الحقيقي المؤكّد هو قائمة تحت `data`.

⚠️ **`AppRoutes.verification` مش بـ`verifiedOnlyRoutes`** — بالعكس
تماماً: هي الشاشة اللي بتخلّي المستخدم يصير موثّقاً، فحجبها عن غير
الموثّق بيقفل الباب اللي هي نفسها مفتاحه.

⚠️ **`VerificationView.loadFailure` مش تفصيل تجميلي**: لو فشل
`GET /api/verification` وعرضنا النموذج بدل شاشة إعادة محاولة، مستخدم
عنده طلب `pending` أصلاً رح يرسل طلباً مكرّراً بلا ما يدري.

⚠️ **حالة غير معروفة → النموذج**: `VerificationRequestStatus.unknown`
بتوقّع على عرض النموذج عن قصد. قيمة ما بنعرفها ما لازم تقفل المستخدم
برّا شاشة بيقدر يستخدمها.

**شريط الملاحة**: تاباته لازم تطابق فروع `StatefulShellRoute` عدداً وترتيباً —
`goBranch` بترمي لو الفهرس خارج المدى. حالياً تابان (`home` و`profile`)
مقابل فرعين. عند إضافة تاب، أضف فرعه بالراوتر بنفس اللحظة.

**فجوات معروفة**:
- ⚠️ **شكل عنصر الرفض جوّا `rejections` غير مؤكّد** — `GET /api/verification`
  الحقيقي مؤكّد (راجع قسم التوثيق فوق) وفيه مصفوفة `rejections` منفصلة
  على كل طلب، بس وصلنا مثال بمصفوفة فاضية بس (طلب `pending`) — ما عندنا
  شكل عنصر رفض حقيقي بعد. `VerificationRequestModel.fromMap` بتضل
  تجرّب `reason`/`description` مسطّحين على الطلب كخط دفاع أول (تخمين
  موروث من شكل جسم طلب الأدمن)؛ عرض الرفض بيعرض نصاً عاماً لو ما وصلا.
  نقطة التصحيح لما يوصل مثال حقيقي: `VerificationRequestModel.fromMap`.
- ⚠️ **`national_id` مطلوب بالتسجيل وما إله حقل بالواجهة** — بيوصل فاضي
  فبيرجع خطأ تحقق من السيرفر. الحقل موجود بـ`SignUpState` والـ request
  model، فالناقص بس `TextFormField` بـ`sign_up_form.dart` وربطه بـ
  `cubit.nationalIdChanged`، وإضافته لشرط `canSubmit`.
- ⚠️ **تأكيد رمز الاستعادة بيمرّ على endpoint تأكيد البريد** — شاشة
  `verify_reset_code` بتضرب `POST /api/auth/checkCode`، وهو نفسه اللي
  بيستخدمه تأكيد البريد بعد التسجيل. إنه **يقبل رموز الاستعادة** مفترَض
  لا مؤكّد، وكمان مش مؤكّد إذا **بيستهلك الرمز** فيفشل `resetPassword`
  بعده برسالة رمز غير صالح. لو طلع بيستهلكه، البديل إلغاء التحقق
  بالسيرفر والاكتفاء بفحص الشكل — تعديل بـ`VerificationCodeCubit.submit`
  وبس. يحتاج تأكيد من الباك اند.
- ✅ **`citizenshipIndex`/`credibilityIndex` مؤكّدان أخيراً** بمثال
  استجابة حقيقي لـ`GET /api/profile` من `collection.md`
  (`citizenship_score`/`credibility_score`، الثاني براجع كنص عشري
  `"50.00"` لا رقم). الاسم القديم `authenticationIndex` كان تخميناً
  غلط بالمفهوم — القصة الحقيقية بـClickUp سمّتها «مؤشرات المواطنة
  والمصداقية» لا «التوثيق»، فانسمّى الحقل والترجمة `credibility_index`.
  عدّادات التطوع/المساهمات/التراخيص التلاتة **لسه بلا عقد** — أسماء
  المفاتيح مكتوبة بـ`CitizenProfileModel._Keys` كتخمين موثّق.
- ✅ **اسم حقل الصورة بالقراءة مؤكّد `image` أخيراً**، بس ⚠️ **بمستوى
  مختلف عمّا كان مفترَضاً**: المثال الحقيقي بيرجّعه بجانب `user` (`data.image`)
  لا جواه (`data.user.image`). كان هاد باگ حقيقي: `CitizenProfileModel`
  كانت تمرّر بس `data.user` لـ`AuthUserModel.fromMap`، فالصورة ما كانت
  تنقرأ أبداً حتى لو موجودة عند السيرفر. الإصلاح بدمج `container['image']`
  جوّا خريطة المستخدم قبل الإرسال لـ`AuthUserModel.fromMap` — راجع
  `CitizenProfileModel.fromMap`. الأسماء البديلة (`image_url`/`avatar_url`/
  `avatar`/`photo`) بـ`AuthUserModel._avatarKeys` ضلّت كخط دفاع احتياطي
  بس `image` هو المؤكّد فعلياً.
- ⚠️ **إزالة الصورة مبنية على عقد مخمَّن بالكامل** — ما في endpoint
  مخصّص، فـ`ProfileRepository.removeAvatar` بيبعت نفس
  `POST /api/profile/update` بحقل `image` **نصّي فاضي** (لا `null` —
  `multipart/form-data` ما بيحمل قيمة فاضية غير نص فاضي). الافتراض إن
  الباك اند بيقرأ الحقل الفاضي كـ«امسح الصورة الحالية» **لسه ما إله
  مثال استجابة حقيقي**، على عكس الرفع. نقطة التصحيح الوحيدة:
  `ProfileRemoteDataSource.removeAvatar`. الإزالة تفاؤلية بنفس نمط
  الرفع (`ProfileState.avatarRemoved`) وبترجع الصورة القديمة لو فشل
  الطلب.
- ⚠️ **حقول تعديل الهوية (`features/profile/presentation/edit_identity/`)
  غير مؤكّدة** — نفس `POST /api/profile/update` تبع الصورة، بأسماء حقول
  موروثة من عقد `/api/auth/register` المؤكّد (`first_name`، `last_name`،
  `national_id`، `birth_date` بصيغة `YYYY/M/D`) — مش مؤكّدة بشكل مستقل
  لهالمسار. نقطة التصحيح الوحيدة `ProfileRemoteDataSource.updateIdentity`.
  (`national_id` لسه بينبعت من هون رغم غياب حقله بالواجهة — راجع «الرقم
  الوطني — مالك واحد» فوق.)
- ⚠️ **القفل بيعتمد على `verified` بس، مش على طلب توثيق قيد المراجعة** —
  `EditIdentityCubit.isLocked` بيتحدّد من `AccountStatus.verified` فقط.
  لو المستخدم بعت طلب توثيق (`features/verification/`) وصار قيد
  المراجعة، الحساب بيضل `visitor` (ما في قيمة `AccountStatus` مخصّصة
  لـ«قيد المراجعة»)، فالشاشة بتسمح بالتعديل رغم إنه منطقياً خطر: لو
  المستخدم غيّر `national_id` بعد ما بعت صوره، الموظّف يلي عم يراجع
  بيصير عنده رقم مختلف عن يلي بالصور. `AuthUser.verificationAttempts`/
  `expiresAt` أقرب إشارة متوفّرة لـ«قيد المراجعة»، بس معناها بعد
  الإرسال مباشرة **غير مجرَّب**. يحتاج تأكيد من الباك اند قبل ما يصير
  فيه قفل إضافي.

**تناقضات بالـ collection تجاهلناها عمداً**:
- جسم `login` بالتوثيق بيسرد `first_name` و`birth_date` و
  `password_confirmation` كحقول مطلوبة — واضح إنه جسم `register` منسوخ
  بالغلط. بنبعت `email` و`password` فقط.
- نفس الشي بـ`logout` و`forgetPassword` (فيهم `fcm_token` و`role_id`)؛
  بـ`forgetPassword` `email` هو الوحيد المعلّم كمطلوب، فبنبعته لحاله.
- `GET /api/` المسمّى "resend verification" مسار ناقص؛ استخدمنا
  `POST /api/email/verification-notification` (اصطلاح Laravel).

## الشكاوى (`features/complaints/`)

مكتملة — `domain`/`data`/`presentation` بثلاث شاشات: القائمة
(`presentation/complaints/`)، تقديم شكوى (`presentation/submit_complaint/`)،
والتفاصيل (`presentation/complaint_detail/`). تاب ثالث بالشريط السفلي
(بين الرئيسية والملف الشخصي — راجع `AppShellPage`، وعدد فروع
`StatefulShellRoute` يلازم يطابقه).

**المسارات كلها مؤكّدة من Postman collection حقيقي** (لا `collection.md`):

| الإجراء | المسار |
|---|---|
| تقديم شكوى | `POST /api/complains` (multipart) |
| المنشورة | `GET /api/complains/complains` (فلاتر `type`/`category_id`/`sort` + `page`/`page_size`) |
| شكاواي | `GET /api/complains/my-complains` |
| تصويت / إلغاء | `POST`/`DELETE /api/complains/vote` بجسم `{"id"}` |
| إبلاغ | `POST /api/reports` بـ`{"complain_id","type_id","description"}` |

**الحقول المؤكّدة من نفس الـcollection**: `type` (`individual`/`collective`/
`emergency`) · `category_id` ستة ثابتة (١ طرقات · ٢ نفايات · ٣ إنارة ·
٤ مياه · ٥ خدمات عامة · ٦ أخرى، بلا endpoint لجلبها — ثابتة بالكود
عمداً) · `sort` (`priority`/`newest`/`oldest`) · حالات الشكوى
`under_review`/`in_progress`/`closed` (من فلتر ومسار تحديث حالة
الأدمن — خيارا `PUT .../status` المسموحين حرفياً `in_progress`/`closed`).

⚠️ **الطارئة بلا `under_review`** — بتُنشر فوراً بحالة `in_progress`
مباشرة (بلا مراجعة)، بعكس الفردية والجماعية اللي بتضلّوا `under_review`
لحد ما يوافق الموظّف. هاد افتراض التصميم الأصلي (`Complaints
Screens.dc.html`) لا نص صريح من الباك اند — يوزر ستوري #4 بتأكّد
الطارئة بس ما بتنفي وضوحاً حاجة الفردية/الجماعية لمراجعة.

✅ **باگ حقيقي انصلح: اسم حقل رفع الوسائط** — الجسم كان بيرسل
`media[]` (فاضي، نفس اصطلاح `images[]` بالتوثيق)، بينما المثال الحقيقي
بـ`collection.md` بيوضح ترقيم صريح: `media[0]`, `media[1]`... النتيجة
كانت الشكوى تتنشأ بنجاح بس بـ`media: []` — الصور تختفي بصمت بلا أي
خطأ ظاهر بالتطبيق. الإصلاح بـ`ComplaintsRemoteDataSourceImpl.submit`
(حلقة برقم فهرس صريح لكل ملف).

✅ **شكل استجابة القراءة مؤكّد أخيراً بأمثلة حقيقية** (`POST /api/complains`،
`GET /api/complains/complains`، `GET /api/complains/my-complains`).
اكتشافان مهمّان غيّروا `ComplaintModel.fromMap`:
- **التصنيف والموقع كائنان متداخلان لا حقول مسطّحة** — `category:
  {id,name}` (لا `category_id` بـ`my-complains`؛ موجود جنب الكائن
  المتداخل بس باستجابة الإنشاء)، والموقع تحت `location` **أو** `pin`
  (اسمان مختلفان لنفس المفهوم بين استجابتَي القائمة والإنشاء).
  `fromMap` بيجرّب الاثنين دفاعياً.
- **الوسائط أصبحت روابط حقيقية** — `media: [{file_url,...}]`، فـ
  `Complaint.mediaUrls` بتعرض صورة حقيقية بالبطاقة والتفاصيل
  (`Image.network`) بدل الـplaceholder القديم. `photo_placeholder`
  انسمّى استخدامه: صار رسالة فشل تحميل الصورة (`errorBuilder`) لا
  «مافيش صورة قابلة للعرض».

⚠️ **عدّاد التصويت (`votes`/`hasVoted`) لسه بلا عقد** — كل الأمثلة
الحقيقية الواصلة لشكاوى المستخدم نفسه (صفر أصوات منطقياً)، فما ثبت اسم
الحقل الحقيقي بعد لو كان مختلفاً عن التخمين
(`votes_count`/`votes`/`vote_count`، `has_voted`/`voted`/`is_voted`).
نقطة التصحيح الوحيدة لما يوصل مثال فيه صوت فعلي: `ComplaintModel.fromMap`.

⚠️ **حقل `priority_score` وصل بمثال `my-complains` الحقيقي بلا استهلاك
بعد** — على الأغلب النتيجة المركّبة يلي `sort=priority` بيرتّب عليها
(أصوات + قيمة مواطنة). ما انضاف للـdomain entity لعدم وجود استهلاك
حالي بالواجهة — لو احتجناه لعرض «الأولوية» بشكل صريح مستقبلاً، القيمة
جاهزة بالاستجابة.

⚠️ **ترقيم `type_id` بالإبلاغ مخمَّن** — مثال الـcollection الوحيد
(`type_id: 2` لصورة غير لائقة) بيأكّد بس قيمة وحدة. رتّبناها 1-6 بنفس
ترتيب يوزر ستوري #5 (عنيف/غير لائق/مضلّل/مسيء/غير ذي صلة/أخرى)، يطابق
المثال الوحيد المؤكّد. نقطة التصحيح: `ComplaintReportReason`.

**موقع الشكوى الجغرافي**: `core/location/LocationService` (حزمة
`geolocator` جديدة) — عام بـ`core/` لا داخل الميزة، نفس منطق
`ImagePickerService`. بيرمي `LocationServiceException` مصنَّف
(`serviceDisabled`/`permissionDenied`) والشاشة بترجم السبب لرسالة، مش
الخدمة نفسها.

**اسم المكان بدل الإحداثيات** (`describeCoordinates` + حزمة `geocoding`):
تحويل عكسي من إحداثيات لاسم مقروء («المزة، دمشق»)، معروض بتلات أماكن —
بطاقة الشكوى، تفاصيلها، وبطاقة الموقع بشاشة الإرسال — عبر ودجت مشترك
`core/design_system/widgets/PlaceNameText`.

⚠️ **مقصود إنها `geocoding` لا `flutter_map`/`latlong2`**: التانيين
بيرسموا خريطة تفاعلية (تبعيّة أثقل + تايلز + مفتاح خدمة أحياناً)،
وإحنا بدنا **نص بس**. `geocoding` بتغلّف واجهة النظام الأصلية بلا مفتاح
API وبلا widget.

⚠️ **الاسم تحسين عرض لا بيانات أساسية** — `describeCoordinates` بترجّع
`null` بدل ما ترمي لو فشل التحويل (شبكة، منطقة غير مفهرسة، منصّة ما
بتدعم)، و`PlaceNameText` بتعرض الإحداثيات الخام كنص احتياطي. لهيك
التحويل بيصير **بالودجت لا بالـCubit**: ما بيدخل بأي قرار ولا إرسال،
و`Complaint` كيان domain ما لازم يحمل حقلاً مصدره خدمة نظام لا الباك
اند — وكمان القائمة ممكن تعرض عشرات الشكاوى، فتحويلها كلها قبل أول
إطار بيأخّر الشاشة كلها.

⚠️ **`geocoding: ^5.0.0` كسر التوافق مع الأمثلة المتداولة**: الدالة
العامة `placemarkFromCoordinates(...)` صارت ميثود على صنف `Geocoding`،
و`localeIdentifier` النصّي صار `Locale`. وكمان **باراميتر `locale`
بالـconstructor مكسور بهالنسخة** (بينحفظ بلا ما ينمرّر للمنصّة) —
فبنمرّره بالميثود مباشرة. راجع `LocationService.describeCoordinates`.

⚠️ **إذن `INTERNET` كان ناقص من مانيفست `main`** — Flutter بيحطّه
تلقائياً بمانيفست `debug`/`profile` بس (لـhot reload)، فالتطبيق كان
يشتغل تمام وقت التطوير بينما **بناء الـrelease بلا إنترنت إطلاقاً**:
كل الـAPI والصور وتحويل الإحداثيات بتفشل. انضاف لـ
`android/app/src/main/AndroidManifest.xml` — لا تشيله.

**وسائط الشكوى**: `core/media/PickedComplaintMedia` — نوع جديد منفصل عن
`PickedImage` (يقبل فيديو، وبلا قصّ: دليل ميداني لازم يضل كما التُقط).
`ImagePickerService.pickComplaintPhoto`/`pickComplaintVideo` ميثودان
إضافيان على الخدمة العامة الموجودة — نفس سبب `pickDocument` سابقاً.
الرفع بمسار الملف مباشرة (`MultipartFile.fromFile`) لا بايتات بالذاكرة،
لأن الفيديو ممكن يكبر عن ما يصحّ يتحمّل كامل بالرام.

**التصويت بالتفاصيل منفصل عن `ComplaintsCubit` عمداً** — الشكوى بتوصل
لشاشة التفاصيل عبر `extra` (نفس منطق `editIdentity`, بلا استعلام جديد)،
والتصويت هناك محلي بحالة الشاشة نفسها. لما ترجع القائمة، الـ`ComplaintsCubit`
بيعيد التحميل بدل ما يزامن الحالتين — تعقيد مشاركة حالة بين شاشتين
مقابل إعادة طلب رخيصة.

`CustomTextFormField` كسبت `maxLines`/`minLines` (افتراضي `1`، بلا أثر
على أي استخدام قائم) — أول استهلاك لها وصف الشكوى/سبب الإبلاغ، حقول
نص متعدد الأسطر ما كانت الودجت تدعمها قبل.

## الشهادات والمهارات (`features/skills/`)

مكتملة — `domain`/`data`/`presentation` بشاشتين: القائمة
(`presentation/skills/pages/skills_page.dart`) والتفاصيل
(`skill_detail_page.dart`). مدخلها الوحيد بانر «الشهادات والمهارات»
الثابت بأعلى `ProfilePage` (راجع قسم الملف الشخصي) — المسار
`AppRoutes.certificatesAndSkills` (`/profile/certificates-skills`)
كان بيوصل لـ`_TempPage` مؤقّتة، صار يوصل للشاشة الحقيقية.

**المهارة والشهادة موردان منفصلان بالباك اند تماماً** — `App\Enums\SkillType`
(عشرة قيم) و`App\Enums\CertificateRejectionReason` (ثمانية قيم) وصلونا
من كود الباك اند الحقيقي مباشرة، لا تخمين. `SkillsRepositoryImpl.getSkills()`
بتضرب `GET /api/skill/` و`GET /api/certificate` بالتوازي وبتدمجهم
بطبقة data عبر مطابقة `certificate.skillId == skill.id` — حقل
`Skill.certificate` بالتالي **مش حقل حقيقي براجع من `/api/skill/`**،
مضاف بعد الدمج فقط (نفس فكرة `AccountStatus` كاهتمام عابر، بس هون
داخل الميزة نفسها لأنه خاص فيها فقط).

| الإجراء | المسار |
|---|---|
| المهارات | `GET /api/skill/` |
| إضافة مهارة | `POST /api/skill/store` |
| تعديل مهارة | `POST /api/skill/update/{id}` |
| حذف مهارة | `DELETE /api/skill/{id}` |
| الشهادات | `GET /api/certificate` |
| إرفاق شهادة | `POST /api/certificate/store` (`user_skill_id`+`file_path`) |
| استبدال شهادة | `POST /api/certificate/update/{id}` (`file_path` بس) |

⚠️ **شكل استجابة `GET` غير مؤكّد بمثال حقيقي** — نفس فجوة الشكاوى:
عندنا مثال الإرسال بس. `SkillModel`/`CertificateModel.fromMap` بترمي
لو الحقول الأساسية (`id`/`name`/`type` أو `id`/`user_skill_id`) ناقصة،
واسم ملف الشهادة بالقراءة مخمَّن بأكتر من اسم محتمل مجرَّب بالترتيب
(`file_name`/`file_path`/`file`/`file_url`). نقطة التصحيح: نفس
الملفين.

**`CertificateFilePickerService` بـ`core/media/`** — عام نفس سبب
`ImagePickerService`/`LocationService`: أول مستهلك بس، وبيقبل PDF
كمان لا صور بس (`file_picker` حزمة جديدة، `image_picker` بيقصر عالصور).
حد 5 ميغابايت مفروض بواجهة الاختيار (`CertificateFilePickerService.maxSizeInBytes`)
لا بالسيرفر — رفض مبكر بدل ما ينتظر المستخدم رد شبكة على ملف كبير.

⚠️ **`file_picker: ^12.0.0` كسر التوافق مع كل أمثلة الحزمة المتداولة** —
`FilePicker.platform.pickFiles()` (نمط `platform` singleton) صار
`FilePicker.pickFile()`/`pickFiles()` ميثودات static مباشرة، و`PlatformFile.size`
(حقل sync) صار `PlatformFile.length()` (async). لو ظهر خطأ
`undefined_getter` على `platform` أو `size` بعد ترقية الحزمة مستقبلاً،
راجع `CertificateFilePickerService.pickFile`.

**عجلة الحذف بلا Cubit خاص** — `confirmAndDeleteSkill` (بـ
`skill_delete_sheet.dart`) بتستخدم `showConfirmSheet` من `core/design_system/widgets/`
مباشرة وبتنادي `DeleteSkillUseCase` عبر `sl<>()`، نفس نمط
`ComplaintReportSheet`. `showConfirmSheet` نفسها انتقلت لـ`core` من
`features/settings/` (كانت `showSettingsConfirmSheet`) لما احتاجتها
هالميزة — نفس سبب `AppCard`/`ImageSourceSheet`.

**تفاصيل مهارة عبر `extra` بلا Cubit مشترك** — نفس نمط `complaintDetail`:
الكيان بيوصل جاهزاً عبر `GoRouterState.extra`، والتعديل/الشهادة/الحذف
كلها محلية بحالة `SkillDetailPage`. أي نجاح بيرجع `Navigator.pop(true)`
فـ`SkillsPage` تعيد التحميل كامل بدل مزامنة حالة بين شاشتين — القائمة
أرخص من التعقيد.

**`SkillsCubit` عمداً بس `GetSkillsUseCase`** — نفس قرار `ComplaintsCubit`/`ComplaintDetailPage`:
الإضافة/التعديل/الحذف/إرفاق الشهادة بتصير مباشرة من الورقة/الشاشة
المسؤولة عبر `sl<...>()`، وبتعيد تحميل القائمة بعد النجاح بدل ما
الـCubit يحمل كل الحالات الوسيطة لكل عملية.

## خدمات البلدية (`features/municipal_services/`)

مكتملة — شاشة وحدة بلا Cubit معقّد (`GetMunicipalServicesUseCase` بس،
نفس نمط `SkillsCubit`). **بلا أي علاقة بنظام الطابور الفعلي** — توضيح
صريح من صاحب المشروع: تطبيق المواطن ما بيتفاعل مع `Queue/Citizen`
إطلاقاً (لا انضمام، لا مسح QR من داخل التطبيق، لا "دوري الحالي"). أول
قصة من التحديثات الأخيرة بـClickUp عندها Backend حقيقي كامل — الباقي
(المشاريع، الأخبار، نظام النقاط) لسه قصص بلا عقد باك اند.

| الإجراء | المسار |
|---|---|
| قائمة الخدمات | `GET /api/admin/services` |

⚠️ **المسار فيه `/admin/` بس مستخدَم من المواطن فعلياً** — مؤكّد من
صاحب المشروع مباشرة مع مثال استجابة حقيقي كامل (أربع خدمات، كل
الحقول). راجع `ApiEndpoints.municipalServicesIndex`.

**الوقت المقدّر مش حقلاً براجع من الباك اند** — `MunicipalService.estimatedWaitMinutes`
بيتحسب محلياً: `estimated_time_minutes × people_waiting`. `peopleWaiting: 0`
بيعرض «فوري» لا «0 دقيقة» — رقم صفر بمكانه بيوحي بخطأ حسابي لا "تعال هلأ".

**الشدّة اللونية (٣ درجات) مبنية فوق توكنات موجودة أصلاً بلا أي إضافة**:
قصير (≤15 دقيقة) بلون الهوية + `brandSurface`، متوسط (≤35) بـ`secondary`
(كهرماني) + `noticeBackground`، طويل بـ`tertiary` (برتقالي) + تينت 14%
منه محسوب مباشرة (`scheme.tertiary.withValues(alpha: 0.14)`) — بلا توكن
جديد لأجل استخدام واحد.

**الأيقونة حسب `id` الخدمة لا اسمها** — الاسم نص حرّ من الباك اند (يجي
بالإنجليزية بمثال الاستجابة، رغم إن التطبيق عربي أولاً)، فمطابقة أيقونة
عليه هش. الربط بـ`id` الأربعة المؤكّدة (١ وثائق، ٢ تراخيص بناء، ٣ خدمات
مالية، ٤ شكاوى) + أيقونة عامة احتياطية لأي `id` جديد — نفس منطق
`SkillStyle`/`ComplaintStyle` بس بلا حاجة لملف `shared/` مستقل لأن
الشاشة الوحيدة يلي محتاجة الربط هي هاي.

**الترتيب**: النشطة تصاعدياً حسب الوقت المقدّر (الأسرع أولاً)، وغير
النشطة (`status != "active"`) دايماً بآخر القائمة بغض النظر عن أي حساب
وقت — بطاقة معطّلة بصرياً بدل ما تنحذف من القائمة.

⏳ **مدخل مؤقّت**: زر بـ`HomeVerificationPage` (الشاشة المؤقّتة الحالية
لتاب الرئيسية) — راجع `AppRoutes.municipalServices`. لما تُبنى شاشة
Home الحقيقية، هاد المدخل بينتقل لمكانه الطبيعي هناك.

## وسائط المسارات

البيانات الحساسة (البريد، رمز إعادة التعيين) بتنمرّر عبر
`GoRouterState.extra` لا عبر query params — على الويب الـ URL بينحفظ
بسجل المتصفح. راجع `core/router/route_args.dart`.

## الباك اند

`https://187-127-71-164.sslip.io` (staging) — قابل للتجاوز:
`flutter run --dart-define=BASE_URL=...`
