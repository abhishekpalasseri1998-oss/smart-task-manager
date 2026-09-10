import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../tasks/data/datasources/task_local_data_source.dart';
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

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    // 1. Check local Hive box cache first
    try {
      final box = Hive.box(TaskLocalDataSourceImpl.boxName);
      final savedTheme = box.get(_themeKey) as String?;
      if (savedTheme != null) {
        return _parseThemeMode(savedTheme);
      }
    } catch (_) {}

    // 2. Fallback to auth user profile theme
    final authState = ref.watch(authStateChangesProvider);
    return authState.maybeWhen(
      data: (user) => _parseThemeMode(user?.themeMode ?? 'system'),
      orElse: () => ThemeMode.system,
    );
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(String userId, String modeStr) async {
    // Immediately update state in memory for 0ms visual theme toggle
    state = _parseThemeMode(modeStr);

    // Save to local storage
    try {
      final box = Hive.box(TaskLocalDataSourceImpl.boxName);
      await box.put(_themeKey, modeStr);
    } catch (_) {}

    // Background sync to Firestore user document
    try {
      final updateThemeUseCase = ref.read(updateThemeModeUseCaseProvider);
      await updateThemeUseCase(userId: userId, themeMode: modeStr);
    } catch (_) {
      // Ignore background sync errors for smooth local theme operation
    }
  }
}

final themeModeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

/// Provider consumed by MaterialApp to dictate ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeNotifierProvider);
});
