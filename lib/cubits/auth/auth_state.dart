import 'package:equatable/equatable.dart';

import '../../models/app_user.dart';

class AuthState extends Equatable {
  const AuthState({this.user});

  final AppUser? user;

  AuthState copyWith({AppUser? user, bool clearUser = false}) => AuthState(
        user: clearUser ? null : (user ?? this.user),
      );

  @override
  List<Object?> get props => [user];
}
