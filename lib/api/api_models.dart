class ApiResponse<T> {
  final int code;
  final String msg;
  final T data;

  const ApiResponse({required this.code, required this.msg, required this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic dataJson) parseData,
  }) {
    return ApiResponse(
      code: (json['code'] is num) ? (json['code'] as num).toInt() : int.tryParse('${json['code']}') ?? 0,
      msg: (json['msg'] ?? '').toString(),
      data: parseData(json['data']),
    );
  }

  bool get isOk => code == 1;
}

/// GET /sp/index/rcmdFoodList — 食材推荐列表
class RcmdFoodItem {
  final int id;
  final String code;
  final String name;
  final String? suggest;
  final String? healthLabel;
  final String? healthLight;
  final String? largeImageUrl;
  final String? thumbImageUrl;
  final String? joule;
  final String? calory;
  final int? categoryId;
  final String? categoryName;
  final int? categoryRank;
  final String? giValue;
  final String? giLabel;
  final String? glValue;
  final String? glLabel;
  final String? fat;
  final String? protein;
  final String? carbohydrate;
  final String? lights;
  final String? warnings;
  final String? warningScenes;
  final int? weigh;
  final int? rankId;
  final int status;

  const RcmdFoodItem({
    required this.id,
    required this.code,
    required this.name,
    required this.suggest,
    required this.healthLabel,
    required this.healthLight,
    required this.largeImageUrl,
    required this.thumbImageUrl,
    required this.joule,
    required this.calory,
    required this.categoryId,
    required this.categoryName,
    required this.categoryRank,
    required this.giValue,
    required this.giLabel,
    required this.glValue,
    required this.glLabel,
    required this.fat,
    required this.protein,
    required this.carbohydrate,
    required this.lights,
    required this.warnings,
    required this.warningScenes,
    required this.weigh,
    required this.rankId,
    required this.status,
  });

  factory RcmdFoodItem.fromJson(Map<String, dynamic> json) {
    int? intOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse('$v');
    }

    int intReq(dynamic v) => intOrNull(v) ?? 0;

    return RcmdFoodItem(
      id: intReq(json['id']),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      suggest: json['suggest']?.toString(),
      healthLabel: json['health_label']?.toString(),
      healthLight: json['health_light']?.toString(),
      largeImageUrl: json['large_image_url']?.toString(),
      thumbImageUrl: json['thumb_image_url']?.toString(),
      joule: json['joule']?.toString(),
      calory: json['calory']?.toString(),
      categoryId: intOrNull(json['category_id']),
      categoryName: json['category_name']?.toString(),
      categoryRank: intOrNull(json['category_rank']),
      giValue: json['gi_value']?.toString(),
      giLabel: json['gi_label']?.toString(),
      glValue: json['gl_value']?.toString(),
      glLabel: json['gl_label']?.toString(),
      fat: json['fat']?.toString(),
      protein: json['protein']?.toString(),
      carbohydrate: json['carbohydrate']?.toString(),
      lights: json['lights']?.toString(),
      warnings: json['warnings']?.toString(),
      warningScenes: json['warning_scenes']?.toString(),
      weigh: intOrNull(json['weigh']),
      rankId: intOrNull(json['rank_id']),
      status: intReq(json['status']),
    );
  }

  /// 优先大图，用于列表展示（相对路径，展示时需 ApiClient.absoluteUrl）
  String get imagePathForDisplay {
    final large = (largeImageUrl ?? '').trim();
    if (large.isNotEmpty) return large;
    return (thumbImageUrl ?? '').trim();
  }

  String get detailText {
    final s = (suggest ?? '').trim();
    if (s.isNotEmpty) return s;
    final w = (warnings ?? '').trim();
    if (w.isNotEmpty) return w;
    return (categoryName ?? '').trim();
  }
}

class CaipinSummary {
  final int id;
  final String name;
  final String desc;
  final String image;
  final num calory;
  final num protein;
  final num carbohydrate;
  final num water;
  final int? cateId;
  final int status;

  const CaipinSummary({
    required this.id,
    required this.name,
    required this.desc,
    required this.image,
    required this.calory,
    required this.protein,
    required this.carbohydrate,
    required this.water,
    required this.cateId,
    required this.status,
  });

  factory CaipinSummary.fromJson(Map<String, dynamic> json) {
    num _num(dynamic v) => (v is num) ? v : num.tryParse('$v') ?? 0;
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return CaipinSummary(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      desc: (json['desc'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      calory: _num(json['calory']),
      protein: _num(json['protein']),
      carbohydrate: _num(json['carbohydrate']),
      water: _num(json['water']),
      cateId: json['cate_id'] == null ? null : _int(json['cate_id']),
      status: _int(json['status']),
    );
  }
}

/// GET /sp/index/searchCaipin — 菜谱搜索分页
class SearchCaipinListPayload {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final List<CaipinSummary> list;
  final bool hasMore;

  const SearchCaipinListPayload({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.list,
    required this.hasMore,
  });

  factory SearchCaipinListPayload.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    final dataList = (json['data'] as List? ?? const []);
    final hm = json['has_more'];
    return SearchCaipinListPayload(
      total: _int(json['total']),
      perPage: _int(json['per_page']),
      currentPage: _int(json['current_page']),
      lastPage: _int(json['last_page']),
      list: dataList.map((e) => CaipinSummary.fromJson((e as Map).cast<String, dynamic>())).toList(),
      hasMore: hm == true || hm == 1,
    );
  }
}

class CaipinFoodItem {
  final num weight;
  final String name;
  final num calory;
  final num protein;
  final num carbohydrate;
  final num water;
  final num? fat;
  final num? joule;
  final String? suggest;
  final String? healthLabel;
  final String? thumbImageUrl;
  final String? lights;

  const CaipinFoodItem({
    required this.weight,
    required this.name,
    required this.calory,
    required this.protein,
    required this.carbohydrate,
    required this.water,
    required this.fat,
    required this.joule,
    required this.suggest,
    required this.healthLabel,
    required this.thumbImageUrl,
    required this.lights,
  });

  factory CaipinFoodItem.fromJson(Map<String, dynamic> json) {
    num _num(dynamic v) => (v is num) ? v : num.tryParse('$v') ?? 0;
    num? _numOrNull(dynamic v) => v == null ? null : ((v is num) ? v : num.tryParse('$v'));

    return CaipinFoodItem(
      weight: _num(json['weight']),
      calory: _num(json['calory']),
      protein: _num(json['protein']),
      carbohydrate: _num(json['carbohydrate']),
      water: _num(json['water']),
      name: (json['name'] ?? '').toString(),
      suggest: json['suggest']?.toString(),
      healthLabel: json['health_label']?.toString(),
      thumbImageUrl: json['thumb_image_url']?.toString(),
      lights: json['lights']?.toString(),
      joule: _numOrNull(json['joule']),
      fat: _numOrNull(json['fat']),
    );
  }
}

class CaipinStep {
  final int caipinId;
  final int sort;
  final String desc;
  final String image;

  const CaipinStep({
    required this.caipinId,
    required this.sort,
    required this.desc,
    required this.image,
  });

  factory CaipinStep.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return CaipinStep(
      caipinId: _int(json['caipin_id']),
      sort: _int(json['sort']),
      desc: (json['desc'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }
}

class CaipinDetailPayload {
  final CaipinSummary detail;
  final List<CaipinFoodItem> foods;
  final List<CaipinStep> steps;

  const CaipinDetailPayload({
    required this.detail,
    required this.foods,
    required this.steps,
  });

  factory CaipinDetailPayload.fromJson(Map<String, dynamic> json) {
    final foodsJson = (json['foods'] as List? ?? const []);
    final stepsJson = (json['steps'] as List? ?? const []);
    return CaipinDetailPayload(
      detail: CaipinSummary.fromJson((json['detail'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{}),
      foods: foodsJson.map((e) => CaipinFoodItem.fromJson((e as Map).cast<String, dynamic>())).toList(),
      steps: stepsJson.map((e) => CaipinStep.fromJson((e as Map).cast<String, dynamic>())).toList()
        ..sort((a, b) => a.sort.compareTo(b.sort)),
    );
  }
}

class FoodCateIcon {
  final String tagIcon;
  final String tagIconSelected;

  const FoodCateIcon({required this.tagIcon, required this.tagIconSelected});

  factory FoodCateIcon.fromJson(Map<String, dynamic> json) {
    return FoodCateIcon(
      tagIcon: (json['tag_icon'] ?? '').toString(),
      tagIconSelected: (json['tag_icon_selected'] ?? '').toString(),
    );
  }
}

class FoodSubCategory {
  final int id;
  final String name;
  final String image;
  final String desc;
  final int tagId;
  final int rankId;

  const FoodSubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.desc,
    required this.tagId,
    required this.rankId,
  });

  factory FoodSubCategory.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return FoodSubCategory(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      desc: (json['desc'] ?? '').toString(),
      tagId: _int(json['tag_id']),
      rankId: _int(json['rank_id']),
    );
  }
}

class FoodCategory {
  final int id;
  final String name;
  final String tagIcon;
  final String tagIconSelected;
  final int rankId;
  final int tagId;
  final List<FoodSubCategory> subs;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.tagIcon,
    required this.tagIconSelected,
    required this.rankId,
    required this.tagId,
    required this.subs,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    final List subsJson = (json['subs'] as List? ?? const []);
    return FoodCategory(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      tagIcon: (json['tag_icon'] ?? '').toString(),
      tagIconSelected: (json['tag_icon_selected'] ?? '').toString(),
      rankId: _int(json['rank_id']),
      tagId: _int(json['tag_id']),
      subs: subsJson.map((e) => FoodSubCategory.fromJson((e as Map).cast<String, dynamic>())).toList(),
    );
  }
}

class FoodListItem {
  final int id;
  final String name;
  final String? suggest;
  final String? healthLabel;
  final String? thumbImageUrl;
  final String? lights;
  final num? joule;
  final num? calory;
  final num? fat;
  final num? protein;
  final num? carbohydrate;

  const FoodListItem({
    required this.id,
    required this.name,
    required this.suggest,
    required this.healthLabel,
    required this.thumbImageUrl,
    required this.lights,
    required this.joule,
    required this.calory,
    required this.fat,
    required this.protein,
    required this.carbohydrate,
  });

  factory FoodListItem.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    num? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      final parsed = num.tryParse('$v');
      return parsed;
    }

    return FoodListItem(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      suggest: json['suggest']?.toString(),
      healthLabel: json['health_label']?.toString(),
      thumbImageUrl: json['thumb_image_url']?.toString(),
      lights: json['lights']?.toString(),
      joule: _num(json['joule']),
      calory: _num(json['calory']),
      fat: _num(json['fat']),
      protein: _num(json['protein']),
      carbohydrate: _num(json['carbohydrate']),
    );
  }
}

class FoodNutritionItem {
  final int id;
  final String name;
  final String nameEn;
  final String unit;
  final String value;
  final String? nrv;
  final int weigh;
  final int foodId;

  const FoodNutritionItem({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.unit,
    required this.value,
    required this.nrv,
    required this.weigh,
    required this.foodId,
  });

  factory FoodNutritionItem.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return FoodNutritionItem(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      nrv: json['nrv']?.toString(),
      weigh: _int(json['weigh']),
      foodId: _int(json['food_id']),
    );
  }
}

class DietPlanSummary {
  final int id;
  final String name;
  final String? image;
  final int userCount;
  final String cycle;
  final int status;
  final int weigh;
  final int dayCount;

  const DietPlanSummary({
    required this.id,
    required this.name,
    required this.image,
    required this.userCount,
    required this.cycle,
    required this.status,
    required this.weigh,
    required this.dayCount,
  });

  factory DietPlanSummary.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return DietPlanSummary(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      image: json['image']?.toString(),
      userCount: _int(json['user_count']),
      cycle: (json['cycle'] ?? '').toString(),
      status: _int(json['status']),
      weigh: _int(json['weigh']),
      dayCount: _int(json['day_count']),
    );
  }
}

class DietPlanListPayload {
  final int total;
  final int page;
  final int limit;
  final List<DietPlanSummary> list;

  const DietPlanListPayload({
    required this.total,
    required this.page,
    required this.limit,
    required this.list,
  });

  factory DietPlanListPayload.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    final listJson = (json['list'] as List? ?? const []);
    return DietPlanListPayload(
      total: _int(json['total']),
      page: _int(json['page']),
      limit: _int(json['limit']),
      list: listJson.map((e) => DietPlanSummary.fromJson((e as Map).cast<String, dynamic>())).toList(),
    );
  }
}

class DietPlanDetailItem {
  final String qty;
  final String unit;
  final String remark;
  final int sourceId;
  final String sourceName;
  final String sourceType;

  const DietPlanDetailItem({
    required this.qty,
    required this.unit,
    required this.remark,
    required this.sourceId,
    required this.sourceName,
    required this.sourceType,
  });

  factory DietPlanDetailItem.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    return DietPlanDetailItem(
      qty: (json['qty'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
      sourceId: _int(json['source_id']),
      sourceName: (json['source_name'] ?? '').toString(),
      sourceType: (json['source_type'] ?? '').toString(),
    );
  }
}

class DietPlanDayGroup {
  final int planId;
  final int sort;
  final int type;
  final List<DietPlanDetailItem> detail;

  const DietPlanDayGroup({
    required this.planId,
    required this.sort,
    required this.type,
    required this.detail,
  });

  factory DietPlanDayGroup.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
    final listJson = (json['detail'] as List? ?? const []);
    return DietPlanDayGroup(
      planId: _int(json['plan_id']),
      sort: _int(json['sort']),
      type: _int(json['type']),
      detail: listJson.map((e) => DietPlanDetailItem.fromJson((e as Map).cast<String, dynamic>())).toList(),
    );
  }
}

class DietPlanDetailPayload {
  final DietPlanSummary detail;
  final List<DietPlanDayGroup> planDays;
  final int day;

  const DietPlanDetailPayload({
    required this.detail,
    required this.planDays,
    required this.day,
  });

  factory DietPlanDetailPayload.fromJson(Map<String, dynamic> json) {
    final detailJson = (json['detail'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final planDaysJson = (json['planDays'] as List? ?? const []);
    return DietPlanDetailPayload(
      detail: DietPlanSummary.fromJson(detailJson),
      planDays: planDaysJson.map((e) => DietPlanDayGroup.fromJson((e as Map).cast<String, dynamic>())).toList(),
      day: (json['day'] as num?)?.toInt() ?? int.tryParse('${json['day']}') ?? 1,
    );
  }
}

