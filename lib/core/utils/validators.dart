class Validators {
  // Email validate karo
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required!';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email!';
    }
    return null;
  }

  // Password validate karo
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required!';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters!';
    }
    return null;
  }

  // Confirm password validate karo
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required!';
    }
    if (value != password) {
      return 'Passwords do not match!';
    }
    return null;
  }

  // Name validate karo
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required!';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters!';
    }
    return null;
  }

  // General field validate karo
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required!';
    }
    return null;
  }
}
