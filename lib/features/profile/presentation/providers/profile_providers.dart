import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_theme_mode_usecase.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateThemeModeUseCaseProvider = Provider<UpdateThemeModeUseCase>((ref) {
  return UpdateThemeModeUseCase(ref.watch(profileRepositoryProvider));
});

class ProfileControllerNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String themeMode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(updateProfileUseCaseProvider);
      await useCase(userId: userId, name: name, themeMode: themeMode);
      state = const AsyncValue.data(null);
      // Invalidate authStateChangesProvider to reflect updated user profile immediately
      ref.invalidate(authStateChangesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(updateThemeModeUseCaseProvider);
      await useCase(userId: userId, themeMode: themeMode);
      state = const AsyncValue.data(null);
      ref.invalidate(authStateChangesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileControllerNotifier, AsyncValue<void>>(
  ProfileControllerNotifier.new,
);

/// Provider that calculates ThemeMode from Firestore user profile
final themeModeProvider = Provider<ThemeMode>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) {
      if (user == null) return ThemeMode.system;
      switch (user.themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    },
    orElse: () => ThemeMode.system,
  );
});
