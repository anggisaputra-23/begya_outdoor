import 'package:dartz/dartz.dart';
import '../datasources/supabase_datasource.dart';
import '../models/models.dart';

/// Abstract repository untuk Auth operations
abstract class AuthRepository {
  Future<Either<Exception, User>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<Either<Exception, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Exception, User?>> getCurrentUser();

  Future<Either<Exception, void>> signOut();

  Future<Either<Exception, bool>> isUserAuthenticated();
}

/// Concrete implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Exception, User>> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return Left(Exception('Email, password, dan name tidak boleh kosong'));
      }

      if (password.length < 6) {
        return Left(Exception('Password minimal 6 karakter'));
      }

      final user = await dataSource.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      return Right(user);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return Left(Exception('Email dan password tidak boleh kosong'));
      }

      final user = await dataSource.signIn(email: email, password: password);

      return Right(user);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, User?>> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, bool>> isUserAuthenticated() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
