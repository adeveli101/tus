# TUS Score Prediction App

A Flutter application for predicting TUS (Medical Specialization Exam) scores and helping medical students make informed decisions about their department preferences.

## Features

- Department score predictions
- Historical data analysis
- Offline mode support
- Department comparison
- User preferences management
- PDF report generation

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code
- Firebase account (for backend services)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/tus.git
cd tus
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── di/
│   ├── firebase/
│   ├── network/
│   └── storage/
├── features/
│   └── tus_scores/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   ├── repositories/
│       │   └── services/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   ├── services/
│       │   └── usecases/
│       └── presentation/
│           ├── cubit/
│           ├── pages/
│           └── widgets/
└── main.dart
```

## Architecture

The project follows Clean Architecture principles with the following layers:

- **Presentation Layer**: UI components, state management (Cubit)
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: Data sources, repositories, models

## Dependencies

- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Database**: sqflite
- **Backend**: Firebase (Firestore)
- **PDF Generation**: pdf
- **Local Storage**: shared_preferences
- **Network**: dio
- **Code Generation**: freezed, json_serializable

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors who have helped with the project
