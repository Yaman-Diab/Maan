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

## الاختبار

```
flutter test        # 76 اختبار
flutter analyze     # صفر ملاحظات
```

- **Use cases**: `mocktail` لعمل mock لعقود الـ repositories.
- **Cubits**: `bloc_test` للتأكد من تسلسل الحالات.
- **Repository impls**: `HttpClientAdapter` مزيّف للتأكد من شكل الطلب
  ومن تحويل الأخطاء — راجع `test/features/auth/data/auth_repository_impl_test.dart`.
- **DI**: `test/di/service_locator_test.dart` بيتأكد إن كل الرسم بينحلّ.

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

**فجوات معروفة**:
- ⚠️ **`national_id` مطلوب بالتسجيل وما إله حقل بالواجهة** — بيوصل فاضي
  فبيرجع خطأ تحقق من السيرفر. الحقل موجود بـ`SignUpState` والـ request
  model، فالناقص بس `TextFormField` بـ`sign_up_form.dart` وربطه بـ
  `cubit.nationalIdChanged`، وإضافته لشرط `canSubmit`.
- ما في شاشة لإدخال رمز إعادة التعيين بين "نسيت كلمة المرور" وشاشة كلمة
  المرور الجديدة، فـ`PasswordResetArgs.code` بتوصل فاضية.
- `AuthSession.user` لسه `Map<String, dynamic>` لأن الـ collection ما
  بيوثّق شكل استجابة تسجيل الدخول (`{}` فاضية بالأمثلة).

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
