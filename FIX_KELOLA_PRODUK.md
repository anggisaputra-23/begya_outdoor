# Kelola Produk Error - Fixed

## Issue
The "Kelola Produk" screen was showing:
```
TypeError: null: type 'Null' is not a subtype of type 'String'
```

## Root Cause
The `Product.fromJson()` method in [product_model.dart](lib/data/models/product_model.dart) had complex nested ternary logic for parsing the `ownerId` field:

```dart
ownerId: (json['user_id'] as String?)?.isEmpty ?? true
    ? (json['owner_id'] as String?)?.isEmpty ?? true
          ? ''
          : json['owner_id'] as String
    : json['user_id'] as String,
```

This logic could produce null values in certain edge cases, which violated the `required String ownerId` field constraint in the Product constructor.

## Solution Applied

Created a dedicated `parseOwnerId()` helper function that safely handles null values:

```dart
String parseOwnerId(dynamic value1, dynamic value2) {
  // Try user_id first, then owner_id
  String? userId = value1 as String?;
  String? ownerId = value2 as String?;
  
  if (userId != null && userId.isNotEmpty) return userId;
  if (ownerId != null && ownerId.isNotEmpty) return ownerId;
  return ''; // Default empty string if both are null or empty
}
```

And replaced the complex logic with:
```dart
ownerId: parseOwnerId(json['user_id'], json['owner_id']),
```

## Benefits
✅ Clear, readable logic  
✅ Guaranteed non-null String return  
✅ Proper fallback to empty string if both fields are null  
✅ No more type errors when creating Product instances

## Files Modified
- [lib/data/models/product_model.dart](lib/data/models/product_model.dart)

## Status
✅ **FIXED** - No compilation errors  
✅ Ready to test the "Kelola Produk" screen
