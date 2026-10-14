// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get home => 'Главная';

  @override
  String get schedule => 'Расписание';

  @override
  String get feed => 'Лента';

  @override
  String get campus => 'Каталог';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get profileTitle => 'Профиль и настройки';

  @override
  String offline(String date) {
    return 'Нет сети · данные от $date';
  }

  @override
  String get unknownDate => 'неизвестной даты';

  @override
  String get notFound => 'Не найдено';

  @override
  String get backHome => 'На главную';

  @override
  String get uiNewsAndEvents0 => 'Новости и события';

  @override
  String get uiNews1 => 'Новости';

  @override
  String get uiEvents2 => 'События';

  @override
  String get uiSearchTheFeed3 => 'Найти в ленте';

  @override
  String get uiFavorites4 => 'Избранное';

  @override
  String get uiNoResults5 => 'Ничего не найдено';

  @override
  String get uiDetails6 => 'Подробности';

  @override
  String get uiRemoveFromFavorites7 => 'Удалить из избранного';

  @override
  String get uiAddToFavorites8 => 'В избранное';

  @override
  String get uiSavedToFavorites9 => 'В избранном';

  @override
  String get uiSaveToFavorites10 => 'Добавить в избранное';

  @override
  String get uiWeekStateManagement11 => 'Неделя 3: состояние';

  @override
  String get uiSchedule12 => 'Расписание';

  @override
  String get uiStudyGroup13 => 'Учебная группа';

  @override
  String get uiFreeDay14 => 'Свободный день';

  @override
  String get uiNoClassesOnThisDay15 => 'В этот день занятий нет';

  @override
  String get uiCampusDirectory16 => 'Каталог кампуса';

  @override
  String get uiBuildingsAndRooms17 => 'КОРПУСА И АУДИТОРИИ';

  @override
  String get uiFindYourClassroom18 => 'Найдите свою аудиторию';

  @override
  String get uiSearchByBuildingFloorOrRoomNumber19 =>
      'Поиск по названию корпуса, этажу или номеру.';

  @override
  String get uiBuildingFloorOrRoom20 => 'Корпус, этаж или аудитория';

  @override
  String get uiDemoDirectoryGoogleMapsIsPlannedForALaterStage21 =>
      'Демонстрационный каталог · Google Maps появится на следующем этапе.';

  @override
  String get uiNoClassroomsFound22 => 'Аудиторий не найдено';

  @override
  String get uiProfile23 => 'Профиль';

  @override
  String get uiNextClass24 => 'Ближайшее занятие';

  @override
  String get uiNoClassesForTheSelectedGroup25 =>
      'Для выбранной группы занятий нет';

  @override
  String get uiQuickAccess26 => 'Быстрый доступ';

  @override
  String get uiClasses27 => 'Пары';

  @override
  String get uiCampus28 => 'Кампус';

  @override
  String get uiUpcomingEvents29 => 'Ближайшие события';

  @override
  String get uiNoUpcomingEvents30 => 'Ближайших событий нет';

  @override
  String get uiNoNews31 => 'Новостей нет';

  @override
  String get uiRegistration32 => 'Регистрация';

  @override
  String get uiSignIn33 => 'Вход в приложение';

  @override
  String get uiYourStudyDayInOnePlace34 => 'Учебный день — в одном месте.';

  @override
  String get uiName35 => 'Имя';

  @override
  String get uiEnterYourName36 => 'Введите имя';

  @override
  String get uiEnterAValidEmail37 => 'Введите корректный email';

  @override
  String get uiPassword38 => 'Пароль';

  @override
  String get uiShowPassword39 => 'Показать пароль';

  @override
  String get uiHidePassword40 => 'Скрыть пароль';

  @override
  String get uiAtLeastCharacters41 => 'Минимум 6 символов';

  @override
  String get uiConfirmPassword42 => 'Повторите пароль';

  @override
  String get uiPasswordsDoNotMatch43 => 'Пароли не совпадают';

  @override
  String get uiCreateAccount44 => 'Создать аккаунт';

  @override
  String get uiSignInNow45 => 'Войти';

  @override
  String get uiAlreadyHaveAnAccount46 => 'Уже есть аккаунт';

  @override
  String get uiSignInWithGoogle47 => 'Войти через Google';

  @override
  String get uiResetPassword48 => 'Восстановить пароль';

  @override
  String get uiIfTheAccountExistsAPasswordResetEmailHasBeenSent49 =>
      'Если аккаунт существует, письмо для восстановления отправлено. Проверьте папки «Входящие» и «Спам». Если письмо попало в спам, отметьте его как «Не спам».';

  @override
  String get uiGuest50 => 'Гость';

  @override
  String get uiDemoMode51 => 'Демонстрационный режим';

  @override
  String get uiCouldNotLoadTheFirestoreProfile52 =>
      'Не удалось загрузить профиль Firestore';

  @override
  String get uiNameNotSpecified53 => 'Имя не указано';

  @override
  String get uiCancel54 => 'Отмена';

  @override
  String get uiSave55 => 'Сохранить';

  @override
  String get uiEditName56 => 'Изменить имя';

  @override
  String get uiStudies57 => 'Учёба';

  @override
  String get uiSelectedGroup58 => 'Выбранная группа';

  @override
  String get uiApplication59 => 'Приложение';

  @override
  String get uiTheme60 => 'Тема';

  @override
  String get uiSystem61 => 'Система';

  @override
  String get uiLight62 => 'Светлая';

  @override
  String get uiDark63 => 'Тёмная';

  @override
  String get uiPushNotifications64 => 'Push-уведомления';

  @override
  String get uiPushNotificationsUnavailable65 => 'Push-уведомления недоступны';

  @override
  String get uiConnectionIsNotConfiguredYet66 => 'Подключение ещё не настроено';

  @override
  String get uiInformation67 => 'Информация';

  @override
  String get uiAbout68 => 'О приложении';

  @override
  String get uiScheduleNewsAndCampusDirectoryDemoDataIsLabeled69 =>
      'Расписание, новости и каталог кампуса. Демонстрационные данные отмечены отдельно.';

  @override
  String get uiSignOut70 => 'Выйти из аккаунта';

  @override
  String get uiExitDemo71 => 'Завершить демонстрацию';

  @override
  String get uiCouldNotRefreshData72 => 'Не удалось обновить данные';

  @override
  String get uiRetry73 => 'Повторить';

  @override
  String get uiLoadingData74 => 'Загрузка данных';

  @override
  String get uiDataSource75 => 'Источник данных';

  @override
  String get uiOk76 => 'Понятно';

  @override
  String get uiNotFound77 => 'Не найдено';

  @override
  String get uiThePageOrItemDoesNotExist78 =>
      'Страница или запись не существует';

  @override
  String get uiGoHome79 => 'На главную';

  @override
  String get uiLoadingSettings80 => 'Загружаем настройки…';

  @override
  String get uiCouldNotLoadLocalDataCheckStorageAccessAndTryAgain81 =>
      'Не удалось загрузить локальные данные. Проверьте доступ к хранилищу браузера и повторите попытку.';

  @override
  String get uiNow82 => 'Сейчас';

  @override
  String get allItems => 'Все';

  @override
  String get guest => 'гость';

  @override
  String get lecture => 'Лекция';

  @override
  String get practice => 'Практика';

  @override
  String get lab => 'Лабораторная';

  @override
  String welcome(String name) {
    return 'Добро пожаловать, $name!';
  }

  @override
  String lessonCount(String count) {
    return 'Занятий: $count';
  }

  @override
  String groupLabel(String group) {
    return 'Группа $group';
  }

  @override
  String weekdayLabel(String day) {
    return 'День недели: $day';
  }

  @override
  String roomLabel(String room) {
    return 'Аудитория $room';
  }

  @override
  String floorLabel(String floor) {
    return 'Этаж $floor';
  }

  @override
  String get designTitle => 'Витрина компонентов';

  @override
  String get designLight => 'Светлая тема';

  @override
  String get designDark => 'Тёмная тема';

  @override
  String get designIntro => 'Учебный день начинается здесь';

  @override
  String get designIntroBody =>
      'Расписание, события и места кампуса — в одном ритме.';

  @override
  String get designCardTitle => 'Группа CS-221';

  @override
  String get designCardBody =>
      'Следующая пара в главном корпусе. До начала осталось 20 минут.';

  @override
  String get designCategories => 'Категории';

  @override
  String get designStudy => 'Учёба';

  @override
  String get designEvents => 'События';

  @override
  String get designPlaces => 'Корпуса';

  @override
  String get designNews => 'Новости';

  @override
  String get designFilters => 'Фильтры и действия';

  @override
  String get designRoute => 'Маршрут';

  @override
  String get designSort => 'Сортировка';

  @override
  String get designMap => 'Карта';

  @override
  String get designFavorite => 'В избранное';

  @override
  String get designShare => 'Поделиться';

  @override
  String get designPhoto => 'Иллюстрация встречи выпускников';

  @override
  String get designBadge => 'Событие кампуса';

  @override
  String get designListing => 'Встреча выпускников';

  @override
  String get designLocation => 'Центральная площадь';

  @override
  String get designTime => '18:00';

  @override
  String get designStats => 'В цифрах';

  @override
  String get designSeats => 'Мест';

  @override
  String get designFloor => 'Этаж';

  @override
  String get designDuration => 'Минут';

  @override
  String get designRoom => 'Аудитория';

  @override
  String get designStates => 'Состояния экрана';

  @override
  String get designEmptyTitle => 'На сегодня всё';

  @override
  String get designEmptyBody =>
      'Новых событий пока нет. Загляните сюда чуть позже.';

  @override
  String get designErrorTitle => 'Не удалось загрузить события';

  @override
  String get designErrorBody => 'Проверьте подключение и попробуйте ещё раз.';

  @override
  String get designSheetHandle => 'Ручка нижней панели';

  @override
  String get designFeedback => 'Пример действия выполнен';

  @override
  String get imageNews => 'Иллюстрация новости';

  @override
  String get imageEvent => 'Иллюстрация события';

  @override
  String get imageBuilding => 'Иллюстрация корпуса';

  @override
  String get imageTeacher => 'Аватар преподавателя';

  @override
  String get imageSubject => 'Иллюстрация дисциплины';

  @override
  String get imageLoading => 'Загружаем изображение';

  @override
  String get navMap => 'Карта';

  @override
  String get navProfile => 'Профиль';

  @override
  String get shareContent => 'Поделиться';

  @override
  String get sortContent => 'Сортировка';

  @override
  String get nextClass => 'Следующая пара';

  @override
  String get todayClasses => 'Сегодня';

  @override
  String get routeRoom => 'Маршрут';

  @override
  String get studyCategory => 'Учёба';

  @override
  String get sportCategory => 'Спорт';

  @override
  String get scienceCategory => 'Наука';

  @override
  String get filterContent => 'Фильтры';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get noNotifications => 'Новых уведомлений нет';

  @override
  String get currentClass => 'Идёт сейчас';

  @override
  String get weekLabel => 'Неделя';

  @override
  String get previousWeek => 'Предыдущая неделя';

  @override
  String get nextWeek => 'Следующая неделя';

  @override
  String startsIn(String minutes) {
    return 'через $minutes мин';
  }

  @override
  String readDuration(String minutes) {
    return '$minutes мин';
  }

  @override
  String get copiedContent => 'Ссылка скопирована';

  @override
  String get detailWhere => 'Где';

  @override
  String get detailTeacher => 'Преподаватель';

  @override
  String get detailSubject => 'Дисциплина';

  @override
  String get detailNotes => 'Материалы и заметки';

  @override
  String get detailNext => 'Следующие занятия по этой дисциплине';

  @override
  String get detailMaterials => 'Материалы';

  @override
  String get detailSyllabus => 'Программа курса';

  @override
  String get detailWeekly => 'Расписание на неделю';

  @override
  String get detailSubjects => 'Дисциплины преподавателя';

  @override
  String get detailContact => 'Контакты';

  @override
  String get detailWrite => 'Написать';

  @override
  String get detailCopyEmail => 'Скопировать email';

  @override
  String get detailMap => 'Показать на карте';

  @override
  String get detailRooms => 'Список аудиторий';

  @override
  String get detailCredits => 'Кредиты';

  @override
  String get detailHours => 'Часов в неделю';

  @override
  String get detailAssessment => 'Форма контроля';

  @override
  String get detailDuration => 'Длительность, мин';

  @override
  String get detailTime => 'Время';

  @override
  String get detailFloors => 'Этажи';

  @override
  String get detailCapacity => 'Вместимость';

  @override
  String get detailFloor => 'Этаж';

  @override
  String get detailOffice => 'Кабинет';

  @override
  String get detailMissing => 'Не указано';

  @override
  String get detailNoMaterials => 'Материалы пока не добавлены';

  @override
  String get detailNoLessons => 'Занятий пока нет';

  @override
  String detailRoom(String number) {
    return 'Аудитория: $number';
  }

  @override
  String detailRoomSummary(String floor, String number) {
    return 'Этаж $floor · Аудитория $number';
  }

  @override
  String get detailDemoPlan => 'Демонстрационный план кампуса';

  @override
  String get detailAddress => 'Адрес';

  @override
  String get detailCopy => 'Скопировать';

  @override
  String get detailPhoto => 'Обложка';

  @override
  String get detailShare => 'Скопировать ссылку';

  @override
  String get detailOfficeHours => 'Часы приёма';

  @override
  String get detailCount => 'Аудитории';

  @override
  String detailRoomHint(String floor) {
    return 'Этаж $floor, уточните путь у администратора';
  }

  @override
  String get pastClass => 'Занятие завершено';

  @override
  String get articleAbout => 'О событии';

  @override
  String get articleOrganizer => 'Организатор';

  @override
  String get articlePrice => 'Стоимость участия';

  @override
  String get articleFree => 'Бесплатно';

  @override
  String get articleFacts => 'Главное';

  @override
  String get noUpcomingEvents => 'Новых событий пока нет';

  @override
  String get noUpcomingEventsHint =>
      'Запланированные мероприятия появятся здесь.';

  @override
  String get mapCampus => 'План кампуса';

  @override
  String get mapExpand => 'Развернуть карту';

  @override
  String get mapBannerHint => 'Выберите корпус на плане или разверните карту.';

  @override
  String get mapAllBuildings => 'Все корпуса';

  @override
  String get mapFreeOnly => 'Свободные сейчас';

  @override
  String get mapFree => 'Свободна по расписанию';

  @override
  String get mapOccupied => 'Сейчас идёт занятие';

  @override
  String get mapAvailabilityNote =>
      'Занятость указана по загруженному расписанию всех групп. Бронирования и фактическая занятость не учитываются.';

  @override
  String get mapCheckedAt => 'Состояние на';

  @override
  String get mapEmptyHint =>
      'Попробуйте другую аудиторию, корпус или отключите фильтр свободных аудиторий.';

  @override
  String get mapResetFilters => 'Сбросить фильтры';

  @override
  String get mapClearSearch => 'Очистить поиск';

  @override
  String get mapClose => 'Закрыть';

  @override
  String get mapEquipment => 'Оснащение';

  @override
  String get mapTodaySchedule => 'Занятия в этой аудитории сегодня';

  @override
  String get mapNextClass => 'Следующая пара';

  @override
  String get mapLessonDetails => 'Подробнее о занятии';

  @override
  String get mapFreeCount => 'Свободны по расписанию';

  @override
  String get mapNoBuildings => 'Корпуса пока не добавлены';

  @override
  String get tasksTitle => 'Личные задачи';

  @override
  String get tasksAdd => 'Добавить';

  @override
  String get tasksNew => 'Новая задача';

  @override
  String get tasksName => 'Название задачи';

  @override
  String get tasksNameRequired => 'Введите название задачи';

  @override
  String get tasksNotes => 'Заметка (необязательно)';

  @override
  String get tasksPickDate => 'Назначить дату';

  @override
  String get tasksClearDate => 'Убрать дату';

  @override
  String get tasksNoDate => 'Без срока';

  @override
  String get tasksOverdue => 'Просрочено';

  @override
  String get tasksSaving => 'Сохраняем…';

  @override
  String get tasksEdit => 'Редактировать';

  @override
  String get tasksDelete => 'Удалить';

  @override
  String get tasksDeleteConfirm => 'Удалить задачу?';

  @override
  String get tasksActions => 'Действия задачи';

  @override
  String get tasksComplete => 'Отметить выполнение';

  @override
  String get tasksOpen => 'Активные';

  @override
  String get tasksDone => 'Выполнено';

  @override
  String get tasksEmpty => 'Добавьте своё дело или дедлайн';

  @override
  String get tasksLocalHint => 'Сохраняются на этом устройстве';

  @override
  String get tasksLoadError => 'Не удалось загрузить задачи';

  @override
  String get tasksSaveError =>
      'Не удалось сохранить задачу. Повторите попытку.';

  @override
  String get tasksShowAll => 'Показать все задачи';

  @override
  String get tasksCollapse => 'Свернуть';

  @override
  String get homeCampusNews => 'В кампусе';

  @override
  String homeStartsInHours(String hours, String minutes) {
    return 'через $hours ч $minutes мин';
  }

  @override
  String homeTomorrowAt(String time) {
    return 'завтра в $time';
  }

  @override
  String get feedOldestFirst => 'Сначала ранние';

  @override
  String get feedNewestFirst => 'Сначала поздние';
}
