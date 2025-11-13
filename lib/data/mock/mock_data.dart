import '../models/quote_model.dart';

class MockData {
  static final List<UserModel> mockUsers = [
    UserModel(
      email: 'bohdan@example.com',
      name: 'Богдан Крук',
      password: 'password123',
    ),
    UserModel(
      email: 'ivanna@example.com',
      name: 'Іванна',
      password: 'qwerty',
    ),
  ];

  static final List<QuoteModel> mockQuotes = [
    QuoteModel(
      id: 'q1',
      text: "Не чекай; час ніколи не буде 'правильним'. Почни там, де стоїш.",
      author: "Наполеон Хілл",
      tags: ["motivation", "time"],
      userId: "bohdan@example.com",
      createdAt: "2025-09-01",
    ),
    QuoteModel(
      id: 'q2',
      text: "Мистецтво — це те, що робить життя цікавішим за мистецтво.",
      author: "Еллісу",
      tags: ["art", "life"],
      userId: "ivanna@example.com",
      createdAt: "2025-08-21",
    ),
    QuoteModel(
      id: 'q3',
      text: "Кожна велика подорож починається з першого кроку.",
      author: "Лао Цзи",
      tags: ["philosophy", "life"],
      userId: "bohdan@example.com",
      createdAt: "2025-07-11",
    ),
    QuoteModel(
      id: 'q4',
      text: "Пиши так, ніби ніхто ніколи не буде читати. Потім відредагуй для світу.",
      author: "Анна",
      tags: ["writing", "advice"],
      userId: "ivanna@example.com",
      createdAt: "2025-06-03",
    ),
  ];

  static UserModel? currentUser;
}