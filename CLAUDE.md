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

⏳ **ناقص**: شاشة الإعدادات نفسها — الأنابيب جاهزة، بس `SettingsCubit`
لسه ما إله واجهة. راجع `FLOW.md` › Settings Flow.

## الترجمة

`easy_localization` مع `assets/translations/{en,ar}.json` — 154 مفتاح بالملفين.

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
flutter test        # 284 اختبار
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
| `create_new_password` | `POST /api/auth/resetPassword` |
| `profile` | `GET /api/profile` |

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

**شريط الملاحة**: تاباته لازم تطابق فروع `StatefulShellRoute` عدداً وترتيباً —
`goBranch` بترمي لو الفهرس خارج المدى. حالياً تابان (`home` و`profile`)
مقابل فرعين. عند إضافة تاب، أضف فرعه بالراوتر بنفس اللحظة.

**فجوات معروفة**:
- ⚠️ **`national_id` مطلوب بالتسجيل وما إله حقل بالواجهة** — بيوصل فاضي
  فبيرجع خطأ تحقق من السيرفر. الحقل موجود بـ`SignUpState` والـ request
  model، فالناقص بس `TextFormField` بـ`sign_up_form.dart` وربطه بـ
  `cubit.nationalIdChanged`، وإضافته لشرط `canSubmit`.
- ما في شاشة لإدخال رمز إعادة التعيين بين "نسيت كلمة المرور" وشاشة كلمة
  المرور الجديدة، فـ`PasswordResetArgs.code` بتوصل فاضية.
- ⚠️ **`TokenRefreshService` مبني على نموذج access/refresh غير موجود
  فعلياً** — استجابة `login` الحقيقية فيها توكن JWT واحد (`token`) من
  طراز `tymon/jwt-auth`، وهالمكتبة بترجّع توكن جديد بإعادة إرسال
  التوكن الحالي (عبر `Authorization` header) لـ`/api/auth/refresh`،
  مش `refresh_token` منفصل بالـ body. السلوك الحالي عند 401 بعد
  انتهاء الصلاحية: تسجيل خروج بدل تجديد صامت — آمن بس مش الأفضل.
  يحتاج تأكيد صريح من الباك اند قبل إعادة كتابة `AuthInterceptor`.
- ⚠️ **مؤشرات الملف الشخصي وعدّاداته بلا عقد** — التصميم بيعرض «مؤشر
  المواطنة» و«مؤشر التوثيق» وعدّادات التطوع/المساهمات/التراخيص، وما في
  ولا endpoint بـ`collection.md` بيرجّعهم. `ProfileStats` كل حقولها
  `null` والواجهة بتعرض «—» بدل رقم مخترع. أسماء المفاتيح المتوقّعة
  مكتوبة بـ`CitizenProfileModel._Keys` كتخمين موثّق — لما يثبّتها الباك
  اند، التعديل بملف واحد.
- ⚠️ **رفع الصورة الشخصية مبني على عقد مخمَّن** — `POST /api/profile/avatar`
  بحقل `avatar` (اصطلاح Laravel)، وما إله ذكر بـ`collection.md`. وكمان
  استجابة `/api/profile` ما فيها حقل صورة، فـ`AuthUserModel` بيجرّب
  `avatar_url`/`avatar`/`image_url`/`image`/`photo` بالترتيب. لو ما لقي
  شي بتنعرض أحرف الاسم. المسار بـ`ApiEndpoints.profileAvatar` واسم الحقل
  بـ`ProfileRemoteDataSource._avatarField` — نقطتان بس للتصحيح.
  («Drop photo» بملف التصميم أداة محرّر لا عنصر واجهة.)
- ما في endpoint لحذف الصورة، فورقة الاختيار فيها «كاميرا» و«معرض» بس
  بلا «إزالة الصورة».
- شاشة تعديل بيانات الهوية غير موجودة، فزر «تعديل» ما بينعرض للزائر
  (`ProfileContent.onEditTap` بتوصل `null`). نفس الشي لأيقونة الإعدادات
  بـ`ProfilePage.onSettingsTap` لحد ما تنبني شاشة الإعدادات.

**تناقضات بالـ collection تجاهلناها عمداً**:
- جسم `login` بالتوثيق بيسرد `first_name` و`birth_date` و
  `password_confirmation` كحقول مطلوبة — واضح إنه جسم `register` منسوخ
  بالغلط. بنبعت `email` و`password` فقط.
- نفس الشي بـ`logout` و`forgetPassword` (فيهم `fcm_token` و`role_id`)؛
  بـ`forgetPassword` `email` هو الوحيد المعلّم كمطلوب، فبنبعته لحاله.
- `GET /api/` المسمّى "resend verification" مسار ناقص؛ استخدمنا
  `POST /api/email/verification-notification` (اصطلاح Laravel).

## وسائط المسارات

البيانات الحساسة (البريد، رمز إعادة التعيين) بتنمرّر عبر
`GoRouterState.extra` لا عبر query params — على الويب الـ URL بينحفظ
بسجل المتصفح. راجع `core/router/route_args.dart`.

## الباك اند

`https://187-127-71-164.sslip.io` (staging) — قابل للتجاوز:
`flutter run --dart-define=BASE_URL=...`
