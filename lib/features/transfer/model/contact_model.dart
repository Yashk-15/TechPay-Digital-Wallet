class ContactModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String maskedAccount;

  const ContactModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.maskedAccount,
  });
}
