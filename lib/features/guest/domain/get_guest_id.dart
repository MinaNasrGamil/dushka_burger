
import 'package:dushka_burger/features/guest/domain/guest_repo.dart';

class GetGuestId {
  final GuestRepository repo;

  GetGuestId(this.repo);

  Future<String> call() {
    return repo.getOrCreateGuestId();
  }
}
