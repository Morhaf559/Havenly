class Validators {
  Validators._();

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters for validation
    final phoneDigits = value.replaceAll(RegExp(r'\D'), '');

    // Check minimum length (at least 8 digits)
    if (phoneDigits.length < 8) {
      return 'Phone number must be at least 8 digits';
    }

    // Check maximum length (reasonable limit)
    if (phoneDigits.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    // Check minimum length
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check maximum length
    if (value.length > 20) {
      return 'Password is too long';
    }

    return null;
  }

  /// Validate password confirmation
  /// Returns error message if invalid, null if valid
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'Password confirmation is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate name (first name, last name)
  /// Returns error message if invalid, null if valid
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    // Check minimum length
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    // Check maximum length
    if (value.trim().length > 50) {
      return '$fieldName is too long';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    /* if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) */
    if (!RegExp(r"^[a-zA-Z\u0600-\u06FF\s'-]+$").hasMatch(value.trim())) {
      return '$fieldName contains invalid characters';
    }

    return null;
  }

  /// Validate first name
  static String? validateFirstName(String? value) {
    return validateName(value, fieldName: 'First name');
  }

  /// Validate last name
  static String? validateLastName(String? value) {
    return validateName(value, fieldName: 'Last name');
  }

  /// Validate username
  /// Returns error message if invalid, null if valid
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    // Check minimum length
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Check maximum length
    if (value.trim().length > 30) {
      return 'Username is too long';
    }

    // Check for valid characters (letters, numbers, underscores)
    if (!RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Validate email (if needed in future)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate date of birth
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }

    // Check if date is in the future
    if (value.isAfter(DateTime.now())) {
      return 'Date of birth cannot be in the future';
    }

    // Check minimum age (e.g., 13 years)
    final age = DateTime.now().year - value.year;
    if (age < 13) {
      return 'You must be at least 13 years old';
    }

    // Check maximum age (e.g., 150 years)
    if (age > 150) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }

  /// Validate image/file
  static String? validateImage(String? value, {String fieldName = 'Image'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
