abstract final class Routes {
  static const login = 'login',
      home = 'home',
      schedule = 'schedule',
      feed = 'feed',
      map = 'map',
      profile = 'profile',
      week3 = 'week3',
      design = 'design';
  static const news = 'news',
      event = 'event',
      lesson = 'lesson',
      subject = 'subject',
      teacher = 'teacher';
  static const paths = <String, String>{
    login: '/login',
    home: '/home',
    schedule: '/schedule',
    feed: '/feed',
    map: '/map',
    profile: '/profile',
    week3: '/learning/week3',
    design: '/learning/design',
    news: '/news/:id',
    event: '/event/:id',
    lesson: '/lesson/:id',
    subject: '/subject/:id',
    teacher: '/teacher/:id',
  };
}
