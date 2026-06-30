enum UserRole {
  user,
  reviewer,
  admin;

  String get apiValue => name;

  bool get canReviewInfrastructure =>
      this == UserRole.reviewer || this == UserRole.admin;

  static UserRole fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'reviewer':
        return UserRole.reviewer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}
