import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/profile/data/profile.dart';
import 'package:suhbat/features/profile/data/profile_repository.dart';

final profilesprovider = FutureProvider<Profile>((ref) async {
  final profileData = await ProfileRepository().getProfile();
  return Profile.fromMap(profileData);
});