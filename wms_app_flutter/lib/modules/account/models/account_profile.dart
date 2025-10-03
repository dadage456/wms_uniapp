import 'package:equatable/equatable.dart';

class AccountProfile extends Equatable {
  const AccountProfile({
    required this.user,
    required this.roleGroup,
    required this.postGroup,
  });

  final AccountProfileUser user;
  final String roleGroup;
  final String postGroup;

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return AccountProfile(
      user: AccountProfileUser.fromJson(userJson),
      roleGroup: json['roleGroup']?.toString() ?? '',
      postGroup: json['postGroup']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [user, roleGroup, postGroup];
}

class AccountProfileUser extends Equatable {
  const AccountProfileUser({
    required this.userId,
    required this.userName,
    required this.nickName,
    this.deptName,
    this.phonenumber,
    this.email,
    this.sex,
    this.avatar,
  });

  final int userId;
  final String userName;
  final String nickName;
  final String? deptName;
  final String? phonenumber;
  final String? email;
  final String? sex;
  final String? avatar;

  factory AccountProfileUser.fromJson(Map<String, dynamic> json) {
    final dept = json['dept'] as Map<String, dynamic>?;
    return AccountProfileUser(
      userId: _parseInt(json['userId']),
      userName: json['userName']?.toString() ?? '',
      nickName: json['nickName']?.toString() ?? '',
      deptName: dept != null
          ? (dept['deptName']?.toString() ?? dept['dept_name']?.toString())
          : json['deptName']?.toString(),
      phonenumber: json['phonenumber']?.toString(),
      email: json['email']?.toString(),
      sex: json['sex']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  AccountProfileUpdateRequest toUpdateRequest() {
    return AccountProfileUpdateRequest(
      nickName: nickName,
      phonenumber: phonenumber,
      email: email,
      sex: sex,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        userName,
        nickName,
        deptName,
        phonenumber,
        email,
        sex,
        avatar,
      ];
}

class AccountProfileUpdateRequest {
  const AccountProfileUpdateRequest({
    required this.nickName,
    this.phonenumber,
    this.email,
    this.sex,
  });

  final String nickName;
  final String? phonenumber;
  final String? email;
  final String? sex;

  AccountProfileUpdateRequest copyWith({
    String? nickName,
    String? phonenumber,
    String? email,
    String? sex,
  }) {
    return AccountProfileUpdateRequest(
      nickName: nickName ?? this.nickName,
      phonenumber: phonenumber ?? this.phonenumber,
      email: email ?? this.email,
      sex: sex ?? this.sex,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nickName': nickName,
      'phonenumber': phonenumber,
      'email': email,
      'sex': sex,
    }..removeWhere((key, value) => value == null);
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
