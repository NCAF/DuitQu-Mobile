// lib/utils/constants.dart

class ApiConstants {
  // Base URL - ganti dengan URL API Anda
  static const String baseUrl = 'http://192.168.1.12:8000/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Category Endpoints
  static const String categories = '/categories';
  static const String categoryByType = '/categories/type';

  // Transaction Endpoints
  static const String transactions = '/transactions';
  static const String transactionsByDate = '/transactions/date-range';
  static const String transactionsByCategory = '/transactions/category';

  // Header Options
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add Auth Token
  static void setAuthToken(String token) {
    headers['Authorization'] = 'Bearer $token';
  }
}

class AppConstants {
  // App Info
  static const String appName = 'Money Manager';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Default Values
  static const int itemsPerPage = 10;
  static const String defaultCurrency = 'IDR';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String validationError = 'Please check your input';

  // Success Messages
  static const String saveSuccess = 'Data saved successfully';
  static const String updateSuccess = 'Data updated successfully';
  static const String deleteSuccess = 'Data deleted successfully';
}

class UiConstants {
  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Font Sizes
  static const double fontXS = 12.0;
  static const double fontS = 14.0;
  static const double fontM = 16.0;
  static const double fontL = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Animation Durations
  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
}

class ValidationConstants {
  // Length Constraints
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;

  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
  static const String passwordPattern =
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
  static const String phonePattern = r'^\+?[0-9]{10,13}$';

  // Validation Messages
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword =
      'Password must be at least 6 characters with letters and numbers';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String requiredField = 'This field is required';
}

class StorageKeys {
  static const String themeMode = 'themeMode';
  static const String language = 'language';
  static const String firstRun = 'firstRun';
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String lastSync = 'lastSync';
  static const String cacheExpiry = 'cacheExpiry';
}
