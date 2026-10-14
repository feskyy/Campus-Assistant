import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @home.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home;

  /// No description provided for @schedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get schedule;

  /// No description provided for @feed.
  ///
  /// In ru, this message translates to:
  /// **'Лента'**
  String get feed;

  /// No description provided for @campus.
  ///
  /// In ru, this message translates to:
  /// **'Каталог'**
  String get campus;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль и настройки'**
  String get profileTitle;

  /// No description provided for @offline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети · данные от {date}'**
  String offline(String date);

  /// No description provided for @unknownDate.
  ///
  /// In ru, this message translates to:
  /// **'неизвестной даты'**
  String get unknownDate;

  /// No description provided for @notFound.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено'**
  String get notFound;

  /// No description provided for @backHome.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get backHome;

  /// No description provided for @uiNewsAndEvents0.
  ///
  /// In ru, this message translates to:
  /// **'Новости и события'**
  String get uiNewsAndEvents0;

  /// No description provided for @uiNews1.
  ///
  /// In ru, this message translates to:
  /// **'Новости'**
  String get uiNews1;

  /// No description provided for @uiEvents2.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get uiEvents2;

  /// No description provided for @uiSearchTheFeed3.
  ///
  /// In ru, this message translates to:
  /// **'Найти в ленте'**
  String get uiSearchTheFeed3;

  /// No description provided for @uiFavorites4.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get uiFavorites4;

  /// No description provided for @uiNoResults5.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get uiNoResults5;

  /// No description provided for @uiDetails6.
  ///
  /// In ru, this message translates to:
  /// **'Подробности'**
  String get uiDetails6;

  /// No description provided for @uiRemoveFromFavorites7.
  ///
  /// In ru, this message translates to:
  /// **'Удалить из избранного'**
  String get uiRemoveFromFavorites7;

  /// No description provided for @uiAddToFavorites8.
  ///
  /// In ru, this message translates to:
  /// **'В избранное'**
  String get uiAddToFavorites8;

  /// No description provided for @uiSavedToFavorites9.
  ///
  /// In ru, this message translates to:
  /// **'В избранном'**
  String get uiSavedToFavorites9;

  /// No description provided for @uiSaveToFavorites10.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в избранное'**
  String get uiSaveToFavorites10;

  /// No description provided for @uiWeekStateManagement11.
  ///
  /// In ru, this message translates to:
  /// **'Неделя 3: состояние'**
  String get uiWeekStateManagement11;

  /// No description provided for @uiSchedule12.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get uiSchedule12;

  /// No description provided for @uiStudyGroup13.
  ///
  /// In ru, this message translates to:
  /// **'Учебная группа'**
  String get uiStudyGroup13;

  /// No description provided for @uiFreeDay14.
  ///
  /// In ru, this message translates to:
  /// **'Свободный день'**
  String get uiFreeDay14;

  /// No description provided for @uiNoClassesOnThisDay15.
  ///
  /// In ru, this message translates to:
  /// **'В этот день занятий нет'**
  String get uiNoClassesOnThisDay15;

  /// No description provided for @uiCampusDirectory16.
  ///
  /// In ru, this message translates to:
  /// **'Каталог кампуса'**
  String get uiCampusDirectory16;

  /// No description provided for @uiBuildingsAndRooms17.
  ///
  /// In ru, this message translates to:
  /// **'КОРПУСА И АУДИТОРИИ'**
  String get uiBuildingsAndRooms17;

  /// No description provided for @uiFindYourClassroom18.
  ///
  /// In ru, this message translates to:
  /// **'Найдите свою аудиторию'**
  String get uiFindYourClassroom18;

  /// No description provided for @uiSearchByBuildingFloorOrRoomNumber19.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию корпуса, этажу или номеру.'**
  String get uiSearchByBuildingFloorOrRoomNumber19;

  /// No description provided for @uiBuildingFloorOrRoom20.
  ///
  /// In ru, this message translates to:
  /// **'Корпус, этаж или аудитория'**
  String get uiBuildingFloorOrRoom20;

  /// No description provided for @uiDemoDirectoryGoogleMapsIsPlannedForALaterStage21.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационный каталог · Google Maps появится на следующем этапе.'**
  String get uiDemoDirectoryGoogleMapsIsPlannedForALaterStage21;

  /// No description provided for @uiNoClassroomsFound22.
  ///
  /// In ru, this message translates to:
  /// **'Аудиторий не найдено'**
  String get uiNoClassroomsFound22;

  /// No description provided for @uiProfile23.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get uiProfile23;

  /// No description provided for @uiNextClass24.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшее занятие'**
  String get uiNextClass24;

  /// No description provided for @uiNoClassesForTheSelectedGroup25.
  ///
  /// In ru, this message translates to:
  /// **'Для выбранной группы занятий нет'**
  String get uiNoClassesForTheSelectedGroup25;

  /// No description provided for @uiQuickAccess26.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый доступ'**
  String get uiQuickAccess26;

  /// No description provided for @uiClasses27.
  ///
  /// In ru, this message translates to:
  /// **'Пары'**
  String get uiClasses27;

  /// No description provided for @uiCampus28.
  ///
  /// In ru, this message translates to:
  /// **'Кампус'**
  String get uiCampus28;

  /// No description provided for @uiUpcomingEvents29.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшие события'**
  String get uiUpcomingEvents29;

  /// No description provided for @uiNoUpcomingEvents30.
  ///
  /// In ru, this message translates to:
  /// **'Ближайших событий нет'**
  String get uiNoUpcomingEvents30;

  /// No description provided for @uiNoNews31.
  ///
  /// In ru, this message translates to:
  /// **'Новостей нет'**
  String get uiNoNews31;

  /// No description provided for @uiRegistration32.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get uiRegistration32;

  /// No description provided for @uiSignIn33.
  ///
  /// In ru, this message translates to:
  /// **'Вход в приложение'**
  String get uiSignIn33;

  /// No description provided for @uiYourStudyDayInOnePlace34.
  ///
  /// In ru, this message translates to:
  /// **'Учебный день — в одном месте.'**
  String get uiYourStudyDayInOnePlace34;

  /// No description provided for @uiName35.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get uiName35;

  /// No description provided for @uiEnterYourName36.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get uiEnterYourName36;

  /// No description provided for @uiEnterAValidEmail37.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный email'**
  String get uiEnterAValidEmail37;

  /// No description provided for @uiPassword38.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get uiPassword38;

  /// No description provided for @uiShowPassword39.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get uiShowPassword39;

  /// No description provided for @uiHidePassword40.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get uiHidePassword40;

  /// No description provided for @uiAtLeastCharacters41.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get uiAtLeastCharacters41;

  /// No description provided for @uiConfirmPassword42.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get uiConfirmPassword42;

  /// No description provided for @uiPasswordsDoNotMatch43.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get uiPasswordsDoNotMatch43;

  /// No description provided for @uiCreateAccount44.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get uiCreateAccount44;

  /// No description provided for @uiSignInNow45.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get uiSignInNow45;

  /// No description provided for @uiAlreadyHaveAnAccount46.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт'**
  String get uiAlreadyHaveAnAccount46;

  /// No description provided for @uiSignInWithGoogle47.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get uiSignInWithGoogle47;

  /// No description provided for @uiResetPassword48.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить пароль'**
  String get uiResetPassword48;

  /// No description provided for @uiIfTheAccountExistsAPasswordResetEmailHasBeenSent49.
  ///
  /// In ru, this message translates to:
  /// **'Если аккаунт существует, письмо для восстановления отправлено. Проверьте папки «Входящие» и «Спам». Если письмо попало в спам, отметьте его как «Не спам».'**
  String get uiIfTheAccountExistsAPasswordResetEmailHasBeenSent49;

  /// No description provided for @uiGuest50.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get uiGuest50;

  /// No description provided for @uiDemoMode51.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационный режим'**
  String get uiDemoMode51;

  /// No description provided for @uiCouldNotLoadTheFirestoreProfile52.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить профиль Firestore'**
  String get uiCouldNotLoadTheFirestoreProfile52;

  /// No description provided for @uiNameNotSpecified53.
  ///
  /// In ru, this message translates to:
  /// **'Имя не указано'**
  String get uiNameNotSpecified53;

  /// No description provided for @uiCancel54.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get uiCancel54;

  /// No description provided for @uiSave55.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get uiSave55;

  /// No description provided for @uiEditName56.
  ///
  /// In ru, this message translates to:
  /// **'Изменить имя'**
  String get uiEditName56;

  /// No description provided for @uiStudies57.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get uiStudies57;

  /// No description provided for @uiSelectedGroup58.
  ///
  /// In ru, this message translates to:
  /// **'Выбранная группа'**
  String get uiSelectedGroup58;

  /// No description provided for @uiApplication59.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get uiApplication59;

  /// No description provided for @uiTheme60.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get uiTheme60;

  /// No description provided for @uiSystem61.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get uiSystem61;

  /// No description provided for @uiLight62.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get uiLight62;

  /// No description provided for @uiDark63.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get uiDark63;

  /// No description provided for @uiPushNotifications64.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления'**
  String get uiPushNotifications64;

  /// No description provided for @uiPushNotificationsUnavailable65.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления недоступны'**
  String get uiPushNotificationsUnavailable65;

  /// No description provided for @uiConnectionIsNotConfiguredYet66.
  ///
  /// In ru, this message translates to:
  /// **'Подключение ещё не настроено'**
  String get uiConnectionIsNotConfiguredYet66;

  /// No description provided for @uiInformation67.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get uiInformation67;

  /// No description provided for @uiAbout68.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get uiAbout68;

  /// No description provided for @uiScheduleNewsAndCampusDirectoryDemoDataIsLabeled69.
  ///
  /// In ru, this message translates to:
  /// **'Расписание, новости и каталог кампуса. Демонстрационные данные отмечены отдельно.'**
  String get uiScheduleNewsAndCampusDirectoryDemoDataIsLabeled69;

  /// No description provided for @uiSignOut70.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get uiSignOut70;

  /// No description provided for @uiExitDemo71.
  ///
  /// In ru, this message translates to:
  /// **'Завершить демонстрацию'**
  String get uiExitDemo71;

  /// No description provided for @uiCouldNotRefreshData72.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить данные'**
  String get uiCouldNotRefreshData72;

  /// No description provided for @uiRetry73.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get uiRetry73;

  /// No description provided for @uiLoadingData74.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка данных'**
  String get uiLoadingData74;

  /// No description provided for @uiDataSource75.
  ///
  /// In ru, this message translates to:
  /// **'Источник данных'**
  String get uiDataSource75;

  /// No description provided for @uiOk76.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get uiOk76;

  /// No description provided for @uiNotFound77.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено'**
  String get uiNotFound77;

  /// No description provided for @uiThePageOrItemDoesNotExist78.
  ///
  /// In ru, this message translates to:
  /// **'Страница или запись не существует'**
  String get uiThePageOrItemDoesNotExist78;

  /// No description provided for @uiGoHome79.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get uiGoHome79;

  /// No description provided for @uiLoadingSettings80.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем настройки…'**
  String get uiLoadingSettings80;

  /// No description provided for @uiCouldNotLoadLocalDataCheckStorageAccessAndTryAgain81.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить локальные данные. Проверьте доступ к хранилищу браузера и повторите попытку.'**
  String get uiCouldNotLoadLocalDataCheckStorageAccessAndTryAgain81;

  /// No description provided for @uiNow82.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get uiNow82;

  /// No description provided for @allItems.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allItems;

  /// No description provided for @guest.
  ///
  /// In ru, this message translates to:
  /// **'гость'**
  String get guest;

  /// No description provided for @lecture.
  ///
  /// In ru, this message translates to:
  /// **'Лекция'**
  String get lecture;

  /// No description provided for @practice.
  ///
  /// In ru, this message translates to:
  /// **'Практика'**
  String get practice;

  /// No description provided for @lab.
  ///
  /// In ru, this message translates to:
  /// **'Лабораторная'**
  String get lab;

  /// No description provided for @welcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать, {name}!'**
  String welcome(String name);

  /// No description provided for @lessonCount.
  ///
  /// In ru, this message translates to:
  /// **'Занятий: {count}'**
  String lessonCount(String count);

  /// No description provided for @groupLabel.
  ///
  /// In ru, this message translates to:
  /// **'Группа {group}'**
  String groupLabel(String group);

  /// No description provided for @weekdayLabel.
  ///
  /// In ru, this message translates to:
  /// **'День недели: {day}'**
  String weekdayLabel(String day);

  /// No description provided for @roomLabel.
  ///
  /// In ru, this message translates to:
  /// **'Аудитория {room}'**
  String roomLabel(String room);

  /// No description provided for @floorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Этаж {floor}'**
  String floorLabel(String floor);

  /// No description provided for @designTitle.
  ///
  /// In ru, this message translates to:
  /// **'Витрина компонентов'**
  String get designTitle;

  /// No description provided for @designLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая тема'**
  String get designLight;

  /// No description provided for @designDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная тема'**
  String get designDark;

  /// No description provided for @designIntro.
  ///
  /// In ru, this message translates to:
  /// **'Учебный день начинается здесь'**
  String get designIntro;

  /// No description provided for @designIntroBody.
  ///
  /// In ru, this message translates to:
  /// **'Расписание, события и места кампуса — в одном ритме.'**
  String get designIntroBody;

  /// No description provided for @designCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Группа CS-221'**
  String get designCardTitle;

  /// No description provided for @designCardBody.
  ///
  /// In ru, this message translates to:
  /// **'Следующая пара в главном корпусе. До начала осталось 20 минут.'**
  String get designCardBody;

  /// No description provided for @designCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get designCategories;

  /// No description provided for @designStudy.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get designStudy;

  /// No description provided for @designEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get designEvents;

  /// No description provided for @designPlaces.
  ///
  /// In ru, this message translates to:
  /// **'Корпуса'**
  String get designPlaces;

  /// No description provided for @designNews.
  ///
  /// In ru, this message translates to:
  /// **'Новости'**
  String get designNews;

  /// No description provided for @designFilters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры и действия'**
  String get designFilters;

  /// No description provided for @designRoute.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут'**
  String get designRoute;

  /// No description provided for @designSort.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get designSort;

  /// No description provided for @designMap.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get designMap;

  /// No description provided for @designFavorite.
  ///
  /// In ru, this message translates to:
  /// **'В избранное'**
  String get designFavorite;

  /// No description provided for @designShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get designShare;

  /// No description provided for @designPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Иллюстрация встречи выпускников'**
  String get designPhoto;

  /// No description provided for @designBadge.
  ///
  /// In ru, this message translates to:
  /// **'Событие кампуса'**
  String get designBadge;

  /// No description provided for @designListing.
  ///
  /// In ru, this message translates to:
  /// **'Встреча выпускников'**
  String get designListing;

  /// No description provided for @designLocation.
  ///
  /// In ru, this message translates to:
  /// **'Центральная площадь'**
  String get designLocation;

  /// No description provided for @designTime.
  ///
  /// In ru, this message translates to:
  /// **'18:00'**
  String get designTime;

  /// No description provided for @designStats.
  ///
  /// In ru, this message translates to:
  /// **'В цифрах'**
  String get designStats;

  /// No description provided for @designSeats.
  ///
  /// In ru, this message translates to:
  /// **'Мест'**
  String get designSeats;

  /// No description provided for @designFloor.
  ///
  /// In ru, this message translates to:
  /// **'Этаж'**
  String get designFloor;

  /// No description provided for @designDuration.
  ///
  /// In ru, this message translates to:
  /// **'Минут'**
  String get designDuration;

  /// No description provided for @designRoom.
  ///
  /// In ru, this message translates to:
  /// **'Аудитория'**
  String get designRoom;

  /// No description provided for @designStates.
  ///
  /// In ru, this message translates to:
  /// **'Состояния экрана'**
  String get designStates;

  /// No description provided for @designEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня всё'**
  String get designEmptyTitle;

  /// No description provided for @designEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Новых событий пока нет. Загляните сюда чуть позже.'**
  String get designEmptyBody;

  /// No description provided for @designErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить события'**
  String get designErrorTitle;

  /// No description provided for @designErrorBody.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте подключение и попробуйте ещё раз.'**
  String get designErrorBody;

  /// No description provided for @designSheetHandle.
  ///
  /// In ru, this message translates to:
  /// **'Ручка нижней панели'**
  String get designSheetHandle;

  /// No description provided for @designFeedback.
  ///
  /// In ru, this message translates to:
  /// **'Пример действия выполнен'**
  String get designFeedback;

  /// No description provided for @imageNews.
  ///
  /// In ru, this message translates to:
  /// **'Иллюстрация новости'**
  String get imageNews;

  /// No description provided for @imageEvent.
  ///
  /// In ru, this message translates to:
  /// **'Иллюстрация события'**
  String get imageEvent;

  /// No description provided for @imageBuilding.
  ///
  /// In ru, this message translates to:
  /// **'Иллюстрация корпуса'**
  String get imageBuilding;

  /// No description provided for @imageTeacher.
  ///
  /// In ru, this message translates to:
  /// **'Аватар преподавателя'**
  String get imageTeacher;

  /// No description provided for @imageSubject.
  ///
  /// In ru, this message translates to:
  /// **'Иллюстрация дисциплины'**
  String get imageSubject;

  /// No description provided for @imageLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем изображение'**
  String get imageLoading;

  /// No description provided for @navMap.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @shareContent.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get shareContent;

  /// No description provided for @sortContent.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sortContent;

  /// No description provided for @nextClass.
  ///
  /// In ru, this message translates to:
  /// **'Следующая пара'**
  String get nextClass;

  /// No description provided for @todayClasses.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayClasses;

  /// No description provided for @routeRoom.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут'**
  String get routeRoom;

  /// No description provided for @studyCategory.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get studyCategory;

  /// No description provided for @sportCategory.
  ///
  /// In ru, this message translates to:
  /// **'Спорт'**
  String get sportCategory;

  /// No description provided for @scienceCategory.
  ///
  /// In ru, this message translates to:
  /// **'Наука'**
  String get scienceCategory;

  /// No description provided for @filterContent.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filterContent;

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Новых уведомлений нет'**
  String get noNotifications;

  /// No description provided for @currentClass.
  ///
  /// In ru, this message translates to:
  /// **'Идёт сейчас'**
  String get currentClass;

  /// No description provided for @weekLabel.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get weekLabel;

  /// No description provided for @previousWeek.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущая неделя'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In ru, this message translates to:
  /// **'Следующая неделя'**
  String get nextWeek;

  /// No description provided for @startsIn.
  ///
  /// In ru, this message translates to:
  /// **'через {minutes} мин'**
  String startsIn(String minutes);

  /// No description provided for @readDuration.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String readDuration(String minutes);

  /// No description provided for @copiedContent.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка скопирована'**
  String get copiedContent;

  /// No description provided for @detailWhere.
  ///
  /// In ru, this message translates to:
  /// **'Где'**
  String get detailWhere;

  /// No description provided for @detailTeacher.
  ///
  /// In ru, this message translates to:
  /// **'Преподаватель'**
  String get detailTeacher;

  /// No description provided for @detailSubject.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплина'**
  String get detailSubject;

  /// No description provided for @detailNotes.
  ///
  /// In ru, this message translates to:
  /// **'Материалы и заметки'**
  String get detailNotes;

  /// No description provided for @detailNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующие занятия по этой дисциплине'**
  String get detailNext;

  /// No description provided for @detailMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Материалы'**
  String get detailMaterials;

  /// No description provided for @detailSyllabus.
  ///
  /// In ru, this message translates to:
  /// **'Программа курса'**
  String get detailSyllabus;

  /// No description provided for @detailWeekly.
  ///
  /// In ru, this message translates to:
  /// **'Расписание на неделю'**
  String get detailWeekly;

  /// No description provided for @detailSubjects.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплины преподавателя'**
  String get detailSubjects;

  /// No description provided for @detailContact.
  ///
  /// In ru, this message translates to:
  /// **'Контакты'**
  String get detailContact;

  /// No description provided for @detailWrite.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
  String get detailWrite;

  /// No description provided for @detailCopyEmail.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать email'**
  String get detailCopyEmail;

  /// No description provided for @detailMap.
  ///
  /// In ru, this message translates to:
  /// **'Показать на карте'**
  String get detailMap;

  /// No description provided for @detailRooms.
  ///
  /// In ru, this message translates to:
  /// **'Список аудиторий'**
  String get detailRooms;

  /// No description provided for @detailCredits.
  ///
  /// In ru, this message translates to:
  /// **'Кредиты'**
  String get detailCredits;

  /// No description provided for @detailHours.
  ///
  /// In ru, this message translates to:
  /// **'Часов в неделю'**
  String get detailHours;

  /// No description provided for @detailAssessment.
  ///
  /// In ru, this message translates to:
  /// **'Форма контроля'**
  String get detailAssessment;

  /// No description provided for @detailDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность, мин'**
  String get detailDuration;

  /// No description provided for @detailTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get detailTime;

  /// No description provided for @detailFloors.
  ///
  /// In ru, this message translates to:
  /// **'Этажи'**
  String get detailFloors;

  /// No description provided for @detailCapacity.
  ///
  /// In ru, this message translates to:
  /// **'Вместимость'**
  String get detailCapacity;

  /// No description provided for @detailFloor.
  ///
  /// In ru, this message translates to:
  /// **'Этаж'**
  String get detailFloor;

  /// No description provided for @detailOffice.
  ///
  /// In ru, this message translates to:
  /// **'Кабинет'**
  String get detailOffice;

  /// No description provided for @detailMissing.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get detailMissing;

  /// No description provided for @detailNoMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Материалы пока не добавлены'**
  String get detailNoMaterials;

  /// No description provided for @detailNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Занятий пока нет'**
  String get detailNoLessons;

  /// No description provided for @detailRoom.
  ///
  /// In ru, this message translates to:
  /// **'Аудитория: {number}'**
  String detailRoom(String number);

  /// No description provided for @detailRoomSummary.
  ///
  /// In ru, this message translates to:
  /// **'Этаж {floor} · Аудитория {number}'**
  String detailRoomSummary(String floor, String number);

  /// No description provided for @detailDemoPlan.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационный план кампуса'**
  String get detailDemoPlan;

  /// No description provided for @detailAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get detailAddress;

  /// No description provided for @detailCopy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get detailCopy;

  /// No description provided for @detailPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get detailPhoto;

  /// No description provided for @detailShare.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать ссылку'**
  String get detailShare;

  /// No description provided for @detailOfficeHours.
  ///
  /// In ru, this message translates to:
  /// **'Часы приёма'**
  String get detailOfficeHours;

  /// No description provided for @detailCount.
  ///
  /// In ru, this message translates to:
  /// **'Аудитории'**
  String get detailCount;

  /// No description provided for @detailRoomHint.
  ///
  /// In ru, this message translates to:
  /// **'Этаж {floor}, уточните путь у администратора'**
  String detailRoomHint(String floor);

  /// No description provided for @pastClass.
  ///
  /// In ru, this message translates to:
  /// **'Занятие завершено'**
  String get pastClass;

  /// No description provided for @articleAbout.
  ///
  /// In ru, this message translates to:
  /// **'О событии'**
  String get articleAbout;

  /// No description provided for @articleOrganizer.
  ///
  /// In ru, this message translates to:
  /// **'Организатор'**
  String get articleOrganizer;

  /// No description provided for @articlePrice.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость участия'**
  String get articlePrice;

  /// No description provided for @articleFree.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатно'**
  String get articleFree;

  /// No description provided for @articleFacts.
  ///
  /// In ru, this message translates to:
  /// **'Главное'**
  String get articleFacts;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In ru, this message translates to:
  /// **'Новых событий пока нет'**
  String get noUpcomingEvents;

  /// No description provided for @noUpcomingEventsHint.
  ///
  /// In ru, this message translates to:
  /// **'Запланированные мероприятия появятся здесь.'**
  String get noUpcomingEventsHint;

  /// No description provided for @mapCampus.
  ///
  /// In ru, this message translates to:
  /// **'План кампуса'**
  String get mapCampus;

  /// No description provided for @mapExpand.
  ///
  /// In ru, this message translates to:
  /// **'Развернуть карту'**
  String get mapExpand;

  /// No description provided for @mapBannerHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите корпус на плане или разверните карту.'**
  String get mapBannerHint;

  /// No description provided for @mapAllBuildings.
  ///
  /// In ru, this message translates to:
  /// **'Все корпуса'**
  String get mapAllBuildings;

  /// No description provided for @mapFreeOnly.
  ///
  /// In ru, this message translates to:
  /// **'Свободные сейчас'**
  String get mapFreeOnly;

  /// No description provided for @mapFree.
  ///
  /// In ru, this message translates to:
  /// **'Свободна по расписанию'**
  String get mapFree;

  /// No description provided for @mapOccupied.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас идёт занятие'**
  String get mapOccupied;

  /// No description provided for @mapAvailabilityNote.
  ///
  /// In ru, this message translates to:
  /// **'Занятость указана по загруженному расписанию всех групп. Бронирования и фактическая занятость не учитываются.'**
  String get mapAvailabilityNote;

  /// No description provided for @mapCheckedAt.
  ///
  /// In ru, this message translates to:
  /// **'Состояние на'**
  String get mapCheckedAt;

  /// No description provided for @mapEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте другую аудиторию, корпус или отключите фильтр свободных аудиторий.'**
  String get mapEmptyHint;

  /// No description provided for @mapResetFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get mapResetFilters;

  /// No description provided for @mapClearSearch.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get mapClearSearch;

  /// No description provided for @mapClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get mapClose;

  /// No description provided for @mapEquipment.
  ///
  /// In ru, this message translates to:
  /// **'Оснащение'**
  String get mapEquipment;

  /// No description provided for @mapTodaySchedule.
  ///
  /// In ru, this message translates to:
  /// **'Занятия в этой аудитории сегодня'**
  String get mapTodaySchedule;

  /// No description provided for @mapNextClass.
  ///
  /// In ru, this message translates to:
  /// **'Следующая пара'**
  String get mapNextClass;

  /// No description provided for @mapLessonDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее о занятии'**
  String get mapLessonDetails;

  /// No description provided for @mapFreeCount.
  ///
  /// In ru, this message translates to:
  /// **'Свободны по расписанию'**
  String get mapFreeCount;

  /// No description provided for @mapNoBuildings.
  ///
  /// In ru, this message translates to:
  /// **'Корпуса пока не добавлены'**
  String get mapNoBuildings;

  /// No description provided for @tasksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Личные задачи'**
  String get tasksTitle;

  /// No description provided for @tasksAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get tasksAdd;

  /// No description provided for @tasksNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая задача'**
  String get tasksNew;

  /// No description provided for @tasksName.
  ///
  /// In ru, this message translates to:
  /// **'Название задачи'**
  String get tasksName;

  /// No description provided for @tasksNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите название задачи'**
  String get tasksNameRequired;

  /// No description provided for @tasksNotes.
  ///
  /// In ru, this message translates to:
  /// **'Заметка (необязательно)'**
  String get tasksNotes;

  /// No description provided for @tasksPickDate.
  ///
  /// In ru, this message translates to:
  /// **'Назначить дату'**
  String get tasksPickDate;

  /// No description provided for @tasksClearDate.
  ///
  /// In ru, this message translates to:
  /// **'Убрать дату'**
  String get tasksClearDate;

  /// No description provided for @tasksNoDate.
  ///
  /// In ru, this message translates to:
  /// **'Без срока'**
  String get tasksNoDate;

  /// No description provided for @tasksOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get tasksOverdue;

  /// No description provided for @tasksSaving.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняем…'**
  String get tasksSaving;

  /// No description provided for @tasksEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get tasksEdit;

  /// No description provided for @tasksDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get tasksDelete;

  /// No description provided for @tasksDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу?'**
  String get tasksDeleteConfirm;

  /// No description provided for @tasksActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия задачи'**
  String get tasksActions;

  /// No description provided for @tasksComplete.
  ///
  /// In ru, this message translates to:
  /// **'Отметить выполнение'**
  String get tasksComplete;

  /// No description provided for @tasksOpen.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get tasksOpen;

  /// No description provided for @tasksDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get tasksDone;

  /// No description provided for @tasksEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте своё дело или дедлайн'**
  String get tasksEmpty;

  /// No description provided for @tasksLocalHint.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняются на этом устройстве'**
  String get tasksLocalHint;

  /// No description provided for @tasksLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить задачи'**
  String get tasksLoadError;

  /// No description provided for @tasksSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить задачу. Повторите попытку.'**
  String get tasksSaveError;

  /// No description provided for @tasksShowAll.
  ///
  /// In ru, this message translates to:
  /// **'Показать все задачи'**
  String get tasksShowAll;

  /// No description provided for @tasksCollapse.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть'**
  String get tasksCollapse;

  /// No description provided for @homeCampusNews.
  ///
  /// In ru, this message translates to:
  /// **'В кампусе'**
  String get homeCampusNews;

  /// No description provided for @homeStartsInHours.
  ///
  /// In ru, this message translates to:
  /// **'через {hours} ч {minutes} мин'**
  String homeStartsInHours(String hours, String minutes);

  /// No description provided for @homeTomorrowAt.
  ///
  /// In ru, this message translates to:
  /// **'завтра в {time}'**
  String homeTomorrowAt(String time);

  /// No description provided for @feedOldestFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала ранние'**
  String get feedOldestFirst;

  /// No description provided for @feedNewestFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала поздние'**
  String get feedNewestFirst;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
