/// Клас для зберігання всіх рядкових констант додатку
abstract class AppStrings {
  // Загальні
  static const String appTitle = 'QuoteGallery';
  static const String appSubtitle = 'Збережи улюблені цитати.';

  // Авторизація
  static const String login = 'Вхід';
  static const String register = 'Реєстрація';
  static const String email = 'Електронна пошта';
  static const String password = 'Пароль';
  static const String confirmPassword = 'Повторити пароль';
  static const String name = 'Ім\'я';
  static const String emailPlaceholder = 'email@example.com';
  static const String passwordPlaceholder = 'пароль';
  static const String namePlaceholder = 'Ваше ім\'я';
  static const String loginButton = 'Увійти';
  static const String registerButton = 'Зареєструватися';
  static const String loginSuccess = 'Успішний вхід';
  static const String registerSuccess = 'Реєстрація успішна';
  static const String logout = 'Вийти з профілю';
  static const String logoutSuccess = 'Ви успішно вийшли';

  // Валідація
  static const String emailRequired = 'Введіть електронну пошту';
  static const String emailInvalid = 'Введіть коректну електронну пошту';
  static const String passwordRequired = 'Введіть пароль';
  static const String passwordMinLength =
      'Пароль має містити мінімум 6 символів';
  static const String confirmPasswordRequired = 'Повторіть пароль';
  static const String passwordsDoNotMatch = 'Паролі не співпадають';
  static const String nameRequired = 'Введіть ім\'я';
  static const String nameMinLength = 'Ім\'я має містити мінімум 2 символи';

  // Помилки авторизації
  static const String errorWeakPassword = 'Пароль занадто слабкий';
  static const String errorEmailAlreadyInUse =
      'Ця електронна пошта вже використовується';
  static const String errorInvalidEmail = 'Невірна електронна пошта';
  static const String errorUserNotFound = 'Користувача не знайдено';
  static const String errorWrongPassword = 'Невірний пароль';
  static const String errorUnknown = 'Сталася помилка. Спробуйте ще раз';

  // Головний екран
  static const String allQuotes = 'Усі цитати';
  static const String myQuotes = 'Мої цитати';
  static const String favorites = 'Улюблені';
  static const String searchPlaceholder = 'Пошук цитат...';
  static const String allAuthors = 'Всі автори';
  static const String allTags = 'Всі теги';
  static const String user = 'Користувач';
  static const String nothingFound = 'Нічого не знайдено.';

  // Профіль
  static const String profile = 'Профіль';
  static const String userNamePlaceholder = 'Ім\'я користувача';
  static const String userEmailPlaceholder = 'email@example.com';
  static const String testCrashlytics = 'Тест Crashlytics';

  // Створення цитати
  static const String createQuote = 'Створити цитату';
  static const String quoteText = 'Текст цитати';
  static const String quoteTextPlaceholder = 'Введи цитату...';
  static const String author = 'Автор';
  static const String authorPlaceholder = 'Ім\'я автора';
  static const String tags = 'Теги (через коми)';
  static const String tagsPlaceholder = 'motivation,life,poetry';
  static const String save = 'Зберегти';
  static const String cancel = 'Відмінити';
  static const String quoteEmpty = 'Цитата порожня';
  static const String quoteSaved = 'Цитату збережено';
  static const String quoteTextMinLength =
      'Текст цитати має містити мінімум 10 символів';
  static const String authorRequired = 'Введіть ім\'я автора';
  static const String authorMinLength =
      'Ім\'я автора має містити мінімум 2 символи';
  static const String tagsEmptyError = 'Теги не можуть бути порожніми';

  // Цитати
  static const String addedToFavorites = 'Додано до улюблених';
  static const String removedFromFavorites = 'Вилучено з улюблених';
  static const String deleteQuote = 'Видалити цитату?';
  static const String delete = 'Видалити';
  static const String quoteDeleted = 'Цитату видалено';
  static const String editPlaceholder = 'Редагування';

  const AppStrings._();
}
