// Static UI only — mock user model with hardcoded data.
class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String bankname;
  final String accountnumber;
  final String accountRef;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.bankname,
    required this.accountnumber,
    required this.accountRef,
  });

  static const mock = UserModel(
    id: 'static-id',
    username: 'John Doe',
    email: 'john@example.com',
    phone: '08012345678',
    bankname: 'Wema Bank',
    accountnumber: '0123456789',
    accountRef: 'ACC_STATIC_123',
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? 'Dear User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      bankname: json['bank_name'] ?? 'Wema Bank',
      accountnumber: json['account_number'] ?? '0123456789',
      accountRef: json['account_reference'] ?? 'ACC_STATIC_123',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel.fromJson(map);

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'phone': phone,
        'bank_name': bankname,
        'account_number': accountnumber,
        'account_reference': accountRef,
      };
}
