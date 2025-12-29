import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadProductImage(File file, String fileName) async {
    await _client.storage
        .from('product-images')
        .upload(fileName, file);

    return _client.storage
        .from('product-images')
        .getPublicUrl(fileName);
  }
}
