import 'package:shared_preferences/shared_preferences.dart';
import 'package:dushka_burger/core/error/exception.dart';
import 'package:dushka_burger/core/error/failure.dart';
import 'package:dushka_burger/features/guest/data/guest_remote_ds.dart';
import 'package:dushka_burger/features/guest/domain/guest_repo.dart';

class GuestRepositoryImpl implements GuestRepository {
  static const _kGuestIdKey = 'guest_id';

  final GuestRemoteDataSource remote;
  final SharedPreferences prefs;

  GuestRepositoryImpl({required this.remote, required this.prefs});

  @override
  Future<String> getOrCreateGuestId() async {
    try {
      // 1) Try cache
      final cached = prefs.getString(_kGuestIdKey);
      if (cached != null && cached.trim().isNotEmpty) return cached;

      // 2) Fetch from API
      final guestId = await remote.getGuestId();

      // 3) Cache it
      await prefs.setString(_kGuestIdKey, guestId);

      return guestId;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message ?? 'null message');
    } on ServerException catch (e) {
      throw ServerFailure(message: 'Server Failure: $e');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
