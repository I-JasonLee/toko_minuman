import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

// import 'package:flutter/material.dart';
// import '../../data/models/product_model.dart';
// import '../../data/repositories/product_repository_impl.dart';

// Update (1)

// enum ProductStatus { initial, loading, loaded, error }

// class ProductProvider extends ChangeNotifier {
//   ProductStatus _status = ProductStatus.initial;
//   List<ProductModel> _products = [];
//   String? _error;

//   ProductStatus get status => _status;
//   List<ProductModel> get products => _products;
//   String? get error => _error;
//   bool get isLoading => _status == ProductStatus.loading;

// Update (1)

//   Future<void> fetchProducts() async {
//     // 1. Set status loading → UI tampilkan spinner
//     _status = ProductStatus.loading;
//     notifyListeners();

//     try {
//       // 2. Hit API — token otomatis di-inject interceptor
//       final response =
//           await DioClient.instance.get(ApiConstants.products);

//       // 3. Parse JSON array menjadi List<ProductModel>
//       final List<dynamic> data = response.data['data'];
//       _products = data.map((e) => ProductModel.fromJson(e)).toList();

//       // 4. Set status loaded → UI tampilkan grid produk
//       _status = ProductStatus.loaded;
//     } on DioException catch (e) {
//       // 5. Jika error → set status error
//       _error = e.response?.data['message'] ?? 'Gagal memuat produk';
//       _status = ProductStatus.error;
//     }

//     notifyListeners();
//   }
// }

// Update (2)

// Status untuk layar dashboard
enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;

  // Getters
  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  // Fungsi untuk mengambil data produk
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      // Ambil daftar produk palsu (Kopi & Matcha) dari Repository
      _products = await ProductRepositoryImpl().getProducts();
      _status = ProductStatus.loaded;
    } catch (e) {
      _error = 'Gagal memuat produk: $e';
      _status = ProductStatus.error;
    }
    
    notifyListeners();
  }
}