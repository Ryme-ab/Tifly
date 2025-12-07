import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthCustomException implements Exception {
  final String message;
  AuthCustomException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  final SupabaseClient client;

  AuthRepository(this.client);

  /// Sign up user using Supabase Auth + profiles table
  Future<UserModel> signUp(UserModel user) async {
    try {
      final response = await client.auth.signUp(
        email: user.email,
        password: user.pwd,
      );

      if (response.user != null) {
        // Insert additional info into profiles table
        await client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': user.fullName,
          'phone': user.phone,
          'email': user.email,
          'pwd': user.pwd,
          'role': user.role,
        });

        return UserModel(
          id: response.user!.id,
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
          pwd: user.pwd,
          role: user.role,
        );
      } else {
        throw AuthCustomException('Sign up failed. Please try again.');
      }
    } on AuthException catch (e) {
      if (e.message.contains('User already registered') ||
          e.message.contains('already exists')) {
        throw AuthCustomException('An account with this email already exists.');
      }
      if (e.message.contains('Password should become at least 6 characters') ||
          e.message.contains('weak_password')) {
        throw AuthCustomException('Password must be at least 6 characters.');
      }
      if (e.message.contains('Unable to validate email address') ||
          e.message.contains('email_address_invalid')) {
        throw AuthCustomException('Email address is invalid.');
      }
      throw AuthCustomException(e.message);
    } on SocketException {
      throw AuthCustomException('Network error. Please check your connection.');
    } catch (e) {
      throw AuthCustomException('Something went wrong. Please try again.');
    }
  }

  /// Login
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthCustomException('Login failed. Please try again.');
      }

      final userId = response.user!.id;

      // Fetch profile
      final profile = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        // Fallback if profile doesn't exist but auth does
        return UserModel(
          id: userId,
          fullName: '',
          email: email,
          phone: '',
          pwd: password,
        );
      }

      return UserModel(
        id: userId,
        fullName: profile['full_name'] ?? '',
        email: profile['email'] ?? email,
        phone: profile['phone'] ?? '',
        pwd:
            password, // usually we don't return pwd back but UserModel requires it
        role: profile['role'] ?? 'parent',
      );
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw AuthCustomException('Incorrect email or password.');
      }
      throw AuthCustomException(e.message);
    } on SocketException {
      throw AuthCustomException('Network error. Please check your connection.');
    } catch (e) {
      throw AuthCustomException('Something went wrong. Please try again.');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
