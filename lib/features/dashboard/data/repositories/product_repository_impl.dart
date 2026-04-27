// Update (1)

// import '../../../../core/constants/api_constants.dart';
// import '../../../../core/services/dio_client.dart';
// import '../../domain/repositories/product_repository.dart';
// import '../models/product_model.dart';

// class ProductRepositoryImpl implements ProductRepository {
//   @override
//   Future<List<ProductModel>> getProducts({
//     int page = 1,
//     int limit = 10,
//     String? category,
//   }) async {
//     final response = await DioClient.instance.get(
//       ApiConstants.products,
//       queryParameters: {
//         'page': page,
//         'limit': limit,
//         if (category != null) 'category': category,
//       },
//     );
//     final List<dynamic> data = response.data['data'];
//     return data.map((e) => ProductModel.fromJson(e)).toList();
//   }

//   @override
//   Future<ProductModel> getProductById(int id) async {
//     final response = await DioClient.instance.get(
//       '${ApiConstants.products}/$id',
//     );
//     return ProductModel.fromJson(response.data['data']);
//   }
// }

// Update (2)

// import '../../domain/repositories/product_repository.dart';
// import '../models/product_model.dart';

// class ProductRepositoryImpl implements ProductRepository {
//   @override
//   Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category}) async {
//     await Future.delayed(const Duration(seconds: 1));
//     return [
//       const ProductModel(id: 1, name: 'Kopi Susu', price: 18000, imageUrl: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80', category: 'Kopi'),
//       const ProductModel(id: 2, name: 'Matcha', price: 22000, imageUrl: 'https://images.unsplash.com/photo-1515823662972-da6a2e4d3002?w=500&q=80', category: 'Teh'),
//     ];
//   }
//   @override
//   Future<ProductModel> getProductById(int id) async {
//     throw UnimplementedError(); 
//   }
// }

// Update (3)

// import '../../domain/repositories/product_repository.dart';
// import '../models/product_model.dart';

// class ProductRepositoryImpl implements ProductRepository {
//   @override
//   Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category}) async {
//     await Future.delayed(const Duration(seconds: 1));
    
//     // Saya menghapus kata 'const' dan mengubah price menjadi double (.0)
//     return [
//       ProductModel(
//         id: 1, 
//         name: 'Kopi Susu', 
//         price: 18000.0, // <-- Ditambah .0
//         imageUrl: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80', 
//         category: 'Kopi'
//       ),
//       ProductModel(
//         id: 2, 
//         name: 'Matcha', 
//         price: 22000.0, // <-- Ditambah .0
//         imageUrl: 'https://images.unsplash.com/photo-1515823662972-da6a2e4d3002?w=500&q=80', 
//         category: 'Teh'
//       ),
//     ];
//   }

//   @override
//   Future<ProductModel> getProductById(int id) async {
//     throw UnimplementedError(); 
//   }
// }

// Uodate (4)

import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      ProductModel(
        id: 1, 
        name: 'Kopi Susu', 
        description: 'Kopi susu aren manis', // <-- Tambahan
        price: 18000.0, 
        stock: 50, // <-- Tambahan
        category: 'Kopi',
        imageUrl: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80', 
        isActive: true, // <-- Tambahan
      ),
      ProductModel(
        id: 2, 
        name: 'Matcha', 
        description: 'Teh hijau jepang', // <-- Tambahan
        price: 22000.0, 
        stock: 30, // <-- Tambahan
        category: 'Teh',
        imageUrl: 'https://images.unsplash.com/photo-1515823662972-da6a2e4d3002?w=500&q=80', 
        isActive: true, // <-- Tambahan
      ),
    ];
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    throw UnimplementedError(); 
  }
}