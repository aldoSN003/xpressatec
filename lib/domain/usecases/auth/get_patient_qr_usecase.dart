import 'dart:typed_data';

import '../../repositories/auth_repository.dart';

class GetPatientQrUseCase {
  GetPatientQrUseCase({required this.repository});

  final AuthRepository repository;

  Future<Uint8List> call(String uuid) {
    return repository.getPatientQr(uuid);
  }
}
