class Validators {
  Validators._();

  static String? requiredField(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? name(String? value) {
    final required = requiredField(value, field: 'Name');
    if (required != null) return required;
    if (value!.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, field: 'Email');
    if (required != null) return required;
    final regex = RegExp(r'^[\w.\-]+@[\w.\-]+\.\w{2,}$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, field: 'Password');
    if (required != null) return required;
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final required = requiredField(value, field: 'Confirm password');
    if (required != null) return required;
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? mobile(String? value) {
    final required = requiredField(value, field: 'Mobile number');
    if (required != null) return required;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? address(String? value) {
    final required = requiredField(value, field: 'Address');
    if (required != null) return required;
    if (value!.trim().length < 8) {
      return 'Enter a complete address';
    }
    return null;
  }

  static String? pincode(String? value) {
    final required = requiredField(value, field: 'Pincode');
    if (required != null) return required;
    if (!RegExp(r'^\d{6}$').hasMatch(value!.trim())) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }
}
