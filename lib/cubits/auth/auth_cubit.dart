import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  void selectUser(AppUser user) => emit(AuthState(user: user));

  void logout() => emit(const AuthState());
}
