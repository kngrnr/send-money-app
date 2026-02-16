# Send Money App

A Flutter application for sending money with user authentication, wallet management, and transaction history tracking.

## About the Project

Send Money App is a mobile application built with Flutter that enables users to:
- **Authentication**: Login Workflow
- **Wallet Management**: View and manage wallet balance
- **Send Money**: Transfer funds to other users
- **Transaction History**: Track all transactions with detailed records

The app follows clean architecture principles with separation of concerns using BLoC pattern for state management.

## Features

- User authentication and authorization
- Real-time wallet balance updates
- Send money to other users
- Complete transaction history
- Mock API for development and testing

## Project Structure

```
lib/
├── main.dart
└── src/
    ├── core/          # Core utilities and constants
    ├── data/          # Data layer (repositories, models)
    └── presentation/  # UI layer (pages, cubits)

test/
├── cubits/           # BLoC tests
├── models/           # Model tests
├── network/          # API tests
├── pages/            # UI tests
├── repositories/     # Repository tests
└── usecases/         # Use case tests
```

## Prerequisites

- **FVM** (Flutter Version Manager) - [Install here](https://fvm.app/)
- **Flutter 3.27.4** (managed via FVM)
- **Dart 3.6+** (included with Flutter)
- **iOS 11.0+** or **Android 5.0+**

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd send-money-app
```

2. Set Flutter version using FVM:
```bash
fvm install 3.27.4
fvm use 3.27.4
```

If you don't have FVM installed, install it first:
```bash
# macOS (using Homebrew)
brew install fvm

# Or download from: https://fvm.app/
```

3. Install dependencies:
```bash
fvm flutter pub get
```

4. Generate the necessary files (if using build_runner):
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## How to Run

Run the app on your connected device or emulator:

```bash
fvm flutter run
```


For iOS:
```bash
fvm flutter run -d iOS
```

For Android:
```bash
fvm flutter run -d Android
```

## How to Test

### Run All Tests

```bash
fvm flutter test
```

### Run Specific Test File

```bash
fvm flutter test test/cubits/auth_cubit_test.dart
```

### Test Categories

- **Unit Tests**: Core business logic, models, and use cases
- **Repository Tests**: Data layer and API interactions
- **BLoC Tests**: State management with Cubit
- **Widget Tests**: UI components and pages

## Mock API

This project uses a **custom mock API** created for development and testing purposes. 

**Mock API Repository**: [kngrnr/mock-send-money-api](https://github.com/kngrnr/mock-send-money-api)

### Test User Credentials

Use the following credentials to test the app:

| Username | Password |
|----------|----------|
| `king123` | `123456` |
| `juan123` | `abcdef` |

**Note**: When sending money, use the recipient's username (e.g., `king123` or `juan123`) as the destination username.

## Architecture Documentation

For detailed information about the app's architecture, see:
- [Class Diagram](docs/architecture/class-diagram.md)
- [Authentication Sequence](docs/sequences/auth-sequence.md)
- [Send Money Sequence](docs/sequences/send-money-sequence.md)
- [View Transactions Sequence](docs/sequences/view-transactions-sequence.md)
