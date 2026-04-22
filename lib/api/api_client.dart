import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_models.dart';

class ApiException implements Exception {
  final String message;
  final int? httpStatus;
  final int? apiCode;

  const ApiException(this.message, {this.httpStatus, this.apiCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  /// 站点根域名（图片等相对路径只拼此地址，不含 index.php）
  static const String origin = 'https://audio.3dmaxmo.com';

  /// 接口入口脚本（与 [origin] 组合为完整 API 根路径）
  static const String indexPhp = 'index.php';

  /// API 根：`origin` + `/` + `index.php`，请求形如 `.../index.php/sp/index/...`
  static String get apiBaseUrl => '$origin/$indexPhp';

  /// 相对路径图片等转为完整 URL（仅使用 [origin]，不经过 index.php）
  static String absoluteUrl(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    if (!u.startsWith('/')) return '$origin/$u';
    return '$origin$u';
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$path').replace(queryParameters: query);
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw ApiException('网络请求失败: ${resp.statusCode}', httpStatus: resp.statusCode);
    }

    final dynamic decoded = json.decode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('返回数据格式错误（非 JSON 对象）');
    }
    return decoded;
  }

  Future<ApiResponse<T>> _getApi<T>(
    String path, {
    Map<String, String>? query,
    required T Function(dynamic dataJson) parseData,
  }) async {
    final jsonMap = await _getJson(path, query: query);
    final res = ApiResponse<T>.fromJson(jsonMap, parseData: parseData);
    if (!res.isOk) {
      throw ApiException(res.msg.isEmpty ? '接口返回错误' : res.msg, apiCode: res.code);
    }
    return res;
  }

  /// GET /sp/index/recommendFoodList — 食谱推荐
  Future<List<CaipinSummary>> recommendFoodList() async {
    final res = await _getApi<List<CaipinSummary>>(
      '/sp/index/recommendFoodList',
      parseData: (d) {
        if (d is List) {
          return d
              .map((e) => CaipinSummary.fromJson((e as Map).cast<String, dynamic>()))
              .toList();
        }
        return const <CaipinSummary>[];
      },
    );
    return res.data;
  }

  /// GET /sp/index/rcmdFoodList — 食材推荐
  Future<List<RcmdFoodItem>> rcmdFoodList() async {
    final res = await _getApi<List<RcmdFoodItem>>(
      '/sp/index/rcmdFoodList',
      parseData: (d) {
        if (d is List) {
          return d
              .map((e) => RcmdFoodItem.fromJson((e as Map).cast<String, dynamic>()))
              .toList();
        }
        return const <RcmdFoodItem>[];
      },
    );
    return res.data;
  }

  /// GET /sp/index/searchCaipin?page=&limit=&keyword=
  Future<SearchCaipinListPayload> searchCaipin({
    int? page,
    required int limit,
    String? keyword,
  }) async {
    final query = <String, String>{'limit': limit.toString()};
    if (page != null) {
      query['page'] = page.toString();
    }
    final kw = (keyword ?? '').trim();
    if (kw.isNotEmpty) {
      query['keyword'] = kw;
    }
    final res = await _getApi<SearchCaipinListPayload>(
      '/sp/index/searchCaipin',
      query: query,
      parseData: (d) => SearchCaipinListPayload.fromJson((d as Map).cast<String, dynamic>()),
    );
    return res.data;
  }

  /// GET /sp/index/getCaipinDetail?id=
  Future<CaipinDetailPayload> getCaipinDetail(int id) async {
    final res = await _getApi<CaipinDetailPayload>(
      '/sp/index/getCaipinDetail',
      query: {'id': id.toString()},
      parseData: (d) => CaipinDetailPayload.fromJson((d as Map).cast<String, dynamic>()),
    );
    return res.data;
  }

  /// GET /sp/index/foodCateList
  Future<List<FoodCategory>> getFoodCateList() async {
    final res = await _getApi<List<FoodCategory>>(
      '/sp/index/foodCateList',
      parseData: (d) {
        if (d is List) {
          return d
              .map((e) => FoodCategory.fromJson((e as Map).cast<String, dynamic>()))
              .toList();
        }
        return const <FoodCategory>[];
      },
    );
    return res.data;
  }

  /// GET /sp/index/foodList?rank_id=
  Future<List<FoodListItem>> getFoodList({required int rankId}) async {
    final res = await _getApi<List<FoodListItem>>(
      '/sp/index/foodList',
      query: {'rank_id': rankId.toString()},
      parseData: (d) {
        if (d is List) {
          return d
              .map((e) => FoodListItem.fromJson((e as Map).cast<String, dynamic>()))
              .toList();
        }
        return const <FoodListItem>[];
      },
    );
    return res.data;
  }

  /// GET /sp/index/foodNutritionDetail?food_id=
  Future<List<FoodNutritionItem>> getFoodNutritionDetail({required int foodId}) async {
    final res = await _getApi<List<FoodNutritionItem>>(
      '/sp/index/foodNutritionDetail',
      query: {'food_id': foodId.toString()},
      parseData: (d) {
        if (d is List) {
          return d.map((e) => FoodNutritionItem.fromJson((e as Map).cast<String, dynamic>())).toList();
        }
        return const <FoodNutritionItem>[];
      },
    );
    return res.data;
  }

  /// GET /sp/index/dietPlanList?page=&limit=
  Future<DietPlanListPayload> getDietPlanList({int page = 1, int limit = 10}) async {
    final res = await _getApi<DietPlanListPayload>(
      '/sp/index/dietPlanList',
      query: {'page': page.toString(), 'limit': limit.toString()},
      parseData: (d) => DietPlanListPayload.fromJson((d as Map).cast<String, dynamic>()),
    );
    return res.data;
  }

  /// GET /sp/index/dietPlanDetail?id=&day=
  Future<DietPlanDetailPayload> getDietPlanDetail({required int id, required int day}) async {
    final res = await _getApi<DietPlanDetailPayload>(
      '/sp/index/dietPlanDetail',
      query: {'id': id.toString(), 'day': day.toString()},
      parseData: (d) => DietPlanDetailPayload.fromJson((d as Map).cast<String, dynamic>()),
    );
    return res.data;
  }
}

