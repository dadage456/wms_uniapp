import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wms_app/models/user_info_model.dart';
import 'package:wms_app/models/user_login_info_model.dart';

class UserManager {
  // 用户用来再次的登录信息
  UserLoginInfoModel? _userLoginInfo;
  UserLoginInfoModel? get userLoginInfo => _userLoginInfo;

  // 用户登录后获取的信息
  UserInfoModel? _userInfo;
  UserInfoModel? get userInfo => _userInfo;

  final ValueNotifier<int> _unreadNoticeCount = ValueNotifier<int>(0);
  ValueListenable<int> get unreadNoticeCountListenable => _unreadNoticeCount;
  int get unreadNoticeCount => _unreadNoticeCount.value;

  Set<String> _readNoticeIds = <String>{};
  bool _noticeHistoryLoaded = false;

  UserManager._internal();

  factory UserManager() => _instance;

  static final UserManager _instance = UserManager._internal();

  // 用户是否登录
  bool get isLogin {
    if (_userInfo != null) return true;

    // 如果内存中没有用户信息，检查本地存储是否有登录信息
    return _userLoginInfo != null;
  }



  /// 用户登录
  void login(UserInfoModel userInfo, String name, String password) {
    _userInfo = userInfo;
    _userLoginInfo = UserLoginInfoModel(username: name, password: password);
    UserLoginInfoManage.saveUserLoginInfo(_userLoginInfo!);
    _resetNoticeState();
  }

  /// 更新缓存的用户信息
  void updateUserInfo(UserInfoModel userInfo) {
    _userInfo = userInfo;
  }

  /// 更新缓存的登录凭据（通常用于修改密码后刷新本地存储）
  Future<void> updateStoredCredentials({String? username, String? password}) async {
    if (_userLoginInfo == null) {
      return;
    }

    _userLoginInfo = _userLoginInfo!.copyWith(
      username: username ?? _userLoginInfo!.username,
      password: password ?? _userLoginInfo!.password,
    );

    await UserLoginInfoManage.saveUserLoginInfo(_userLoginInfo!);
  }

  /// 清除用户信息
  Future<void> logout({bool clearSavedLogin = false}) async {
    _userInfo = null;
    if (clearSavedLogin) {
      _userLoginInfo = null;
      await UserLoginInfoManage.clearUserLoginInfo();
    }
    _resetNoticeState();
  }

  Future<void> clear() async {
    _userLoginInfo = null;
    _userInfo = null;
    _resetNoticeState();
  }

  Future<void> loadUserLoginInfo() async {
    _userLoginInfo = await UserLoginInfoManage.loadUserLoginInfo();
  }

  Future<void> ensureNoticeHistoryLoaded() async {
    if (_noticeHistoryLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_noticeStorageKey) ?? <String>[];
    _readNoticeIds = stored.toSet();
    _noticeHistoryLoaded = true;
  }

  bool isNoticeReadSync(String noticeId) {
    if (!_noticeHistoryLoaded) {
      return false;
    }
    return _readNoticeIds.contains(noticeId);
  }

  Future<bool> markNoticeAsRead(String noticeId) async {
    if (noticeId.isEmpty) return false;
    await ensureNoticeHistoryLoaded();
    if (_readNoticeIds.add(noticeId)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_noticeStorageKey, _readNoticeIds.toList());
      return true;
    }
    return false;
  }

  void updateUnreadNoticeCount(int count) {
    if (count < 0) {
      _unreadNoticeCount.value = 0;
    } else {
      _unreadNoticeCount.value = count;
    }
  }

  void _resetNoticeState() {
    _readNoticeIds = <String>{};
    _noticeHistoryLoaded = false;
    _unreadNoticeCount.value = 0;
  }

  String get _noticeStorageKey {
    if (_userInfo != null) {
      return 'notice_read_ids_${_userInfo!.userId}';
    }
    if (_userLoginInfo != null) {
      return 'notice_read_ids_${_userLoginInfo!.username}';
    }
    return 'notice_read_ids_default';
  }
}

class UserLoginInfoManage {
  static const String _userLoginInfoKey = 'user_login_info';

  /// 保存用户登录信息
  static Future<void> saveUserLoginInfo(UserLoginInfoModel userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLoginInfoKey, jsonEncode(userInfo.toJson()));
  }

  /// 从本地存储加载用户登录信息
  static Future<UserLoginInfoModel?> loadUserLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString(_userLoginInfoKey);
    if (userInfoString != null) {
      final userInfoJson = jsonDecode(userInfoString);
      return UserLoginInfoModel.fromJson(userInfoJson);
    }
    return null;
  }

  /// 清除用户登录信息
  static Future<void> clearUserLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userLoginInfoKey);
  }
}
