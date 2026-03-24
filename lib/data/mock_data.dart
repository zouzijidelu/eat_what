// 与 HTML 版本一致的占位数据

class RecipeItem {
  final String id;
  final String title;
  final String desc;
  final List<String> tags;
  final String duration;
  final String category;
  final String imageUrl;

  const RecipeItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.tags,
    required this.duration,
    required this.category,
    required this.imageUrl,
  });
}

class FoodItem {
  final String name;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final bool recommended;

  const FoodItem({
    required this.name,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    this.recommended = false,
  });
}

class FoodCategory {
  final String id;
  final String name;
  final List<FoodSubCategory> items;

  const FoodCategory({required this.id, required this.name, required this.items});
}

class FoodSubCategory {
  final String name;
  final String desc;
  final String img;

  const FoodSubCategory(
      {required this.name, required this.desc, required this.img});
}

class PlanItem {
  final String id;
  final String name;
  final String desc;
  final int days;
  final String imageUrl;

  const PlanItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.days,
    required this.imageUrl,
  });
}

class PlanDaySchedule {
  final String breakfastTitle;
  final String breakfastDesc;
  final String lunchTitle;
  final String lunchDesc;
  final String dinnerTitle;
  final String dinnerDesc;

  const PlanDaySchedule({
    required this.breakfastTitle,
    required this.breakfastDesc,
    required this.lunchTitle,
    required this.lunchDesc,
    required this.dinnerTitle,
    required this.dinnerDesc,
  });
}

class MockData {
  static const _imgRecipe = 'https://placehold.co/224x224/png?text=%E8%8F%9C%E8%B0%B1%E5%9B%BE';
  static const _imgPlaceholder = 'https://placehold.co/256x256/png?text=%E5%8D%A0%E4%BD%8D%E5%9B%BE';
  static const _imgPlan = 'https://placehold.co/200x200/png?text=%E8%AE%A1%E5%88%92';

  static final recipes = [
    RecipeItem(
      id: '1',
      title: '番茄鸡蛋面',
      desc: '酸甜番茄配嫩滑鸡蛋，一碗热面快速回血，适合忙碌工作日。',
      tags: ['快手', '下饭'],
      duration: '15 分钟',
      category: '家常',
      imageUrl: _imgRecipe,
    ),
    RecipeItem(
      id: '2',
      title: '香煎鸡胸沙拉',
      desc: '外焦里嫩的鸡胸搭配清爽蔬菜，饱腹又不负担，适合健身日。',
      tags: ['低脂', '高蛋白'],
      duration: '20 分钟',
      category: '一盘搞定',
      imageUrl: _imgRecipe,
    ),
    RecipeItem(
      id: '3',
      title: '红糖姜茶',
      desc: '暖胃暖心的小甜饮，辛香姜味配红糖回甘，适合微凉的夜晚。',
      tags: ['治愈', '甜口'],
      duration: '10 分钟',
      category: '热饮',
      imageUrl: _imgRecipe,
    ),
  ];

  static final homeFoods = [
    FoodItem(name: '牛油果', subtitle: '优质脂肪', tag: '荐', imageUrl: _imgPlaceholder, recommended: true),
    FoodItem(name: '蓝莓', subtitle: '清爽小甜', tag: '', imageUrl: _imgPlaceholder),
    FoodItem(name: '三文鱼', subtitle: '高蛋白', tag: '', imageUrl: _imgPlaceholder),
    FoodItem(name: '燕麦', subtitle: '耐饿搭子', tag: '', imageUrl: _imgPlaceholder),
  ];

  static final plans = [
    PlanItem(
      id: '轻盈控卡',
      name: '轻盈控卡',
      desc: '减少油炸和高糖，三餐结构更稳，适合想要轻断负担的一周。',
      days: 7,
      imageUrl: _imgPlan,
    ),
    PlanItem(
      id: '元气增肌',
      name: '元气增肌',
      desc: '提高蛋白质与复合碳水占比，训练日更有力，适合力量训练周期。',
      days: 14,
      imageUrl: _imgPlan,
    ),
    PlanItem(
      id: '清淡养胃',
      name: '清淡养胃',
      desc: '少刺激、少油盐，软烂易消化，适合想把饮食"调顺"的阶段。',
      days: 5,
      imageUrl: _imgPlan,
    ),
  ];

  static final foodCategories = [
    FoodCategory(
      id: 'fruit',
      name: '水果',
      items: [
        FoodSubCategory(name: '莓果类', desc: '蓝莓 / 草莓 / 覆盆子', img: 'https://placehold.co/256x256/png?text=%E6%B0%B4%E6%9E%9C'),
        FoodSubCategory(name: '热带水果', desc: '芒果 / 菠萝 / 牛油果', img: 'https://placehold.co/256x256/png?text=%E6%B0%B4%E6%9E%9C'),
        FoodSubCategory(name: '柑橘类', desc: '橙子 / 柠檬 / 柚子', img: 'https://placehold.co/256x256/png?text=%E6%B0%B4%E6%9E%9C'),
        FoodSubCategory(name: '应季精选', desc: '当季更好吃', img: 'https://placehold.co/256x256/png?text=%E6%B0%B4%E6%9E%9C'),
      ],
    ),
    FoodCategory(
      id: 'protein',
      name: '蛋白质',
      items: [
        FoodSubCategory(name: '鱼虾贝', desc: '三文鱼 / 虾 / 扇贝', img: 'https://placehold.co/256x256/png?text=%E8%9B%8B%E7%99%BD'),
        FoodSubCategory(name: '禽肉', desc: '鸡胸 / 鸭胸', img: 'https://placehold.co/256x256/png?text=%E8%9B%8B%E7%99%BD'),
        FoodSubCategory(name: '蛋奶', desc: '鸡蛋 / 酸奶 / 奶酪', img: 'https://placehold.co/256x256/png?text=%E8%9B%8B%E7%99%BD'),
        FoodSubCategory(name: '豆制品', desc: '豆腐 / 豆浆 / 毛豆', img: 'https://placehold.co/256x256/png?text=%E8%9B%8B%E7%99%BD'),
      ],
    ),
    FoodCategory(
      id: 'staple',
      name: '主食',
      items: [
        FoodSubCategory(name: '米面', desc: '米饭 / 面条 / 米粉', img: 'https://placehold.co/256x256/png?text=%E4%B8%BB%E9%A3%9F'),
        FoodSubCategory(name: '全谷物', desc: '燕麦 / 糙米 / 藜麦', img: 'https://placehold.co/256x256/png?text=%E4%B8%BB%E9%A3%9F'),
        FoodSubCategory(name: '薯类', desc: '土豆 / 红薯', img: 'https://placehold.co/256x256/png?text=%E4%B8%BB%E9%A3%9F'),
        FoodSubCategory(name: '面包', desc: '吐司 / 全麦', img: 'https://placehold.co/256x256/png?text=%E4%B8%BB%E9%A3%9F'),
      ],
    ),
    FoodCategory(
      id: 'veg',
      name: '蔬菜',
      items: [
        FoodSubCategory(name: '叶菜', desc: '生菜 / 菠菜 / 油麦菜', img: 'https://placehold.co/256x256/png?text=%E8%94%AC%E8%8F%9C'),
        FoodSubCategory(name: '瓜茄', desc: '番茄 / 黄瓜 / 茄子', img: 'https://placehold.co/256x256/png?text=%E8%94%AC%E8%8F%9C'),
        FoodSubCategory(name: '菌菇', desc: '香菇 / 金针菇', img: 'https://placehold.co/256x256/png?text=%E8%94%AC%E8%8F%9C'),
        FoodSubCategory(name: '根茎', desc: '胡萝卜 / 白萝卜', img: 'https://placehold.co/256x256/png?text=%E8%94%AC%E8%8F%9C'),
      ],
    ),
    FoodCategory(
      id: 'snack',
      name: '零食',
      items: [
        FoodSubCategory(name: '坚果', desc: '杏仁 / 核桃 / 腰果', img: 'https://placehold.co/256x256/png?text=%E9%9B%B6%E9%A3%9F'),
        FoodSubCategory(name: '酸奶杯', desc: '酸奶 + 水果', img: 'https://placehold.co/256x256/png?text=%E9%9B%B6%E9%A3%9F'),
        FoodSubCategory(name: '低糖甜点', desc: '更轻的满足', img: 'https://placehold.co/256x256/png?text=%E9%9B%B6%E9%A3%9F'),
        FoodSubCategory(name: '小食', desc: '海苔 / 玉米片', img: 'https://placehold.co/256x256/png?text=%E9%9B%B6%E9%A3%9F'),
      ],
    ),
  ];

  static final foodItemsByCategory = {
    '莓果类': [
      {'name': '蓝莓', 'tag': '清爽', 'kcal': '57kcal/100g'},
      {'name': '草莓', 'tag': '维C', 'kcal': '32kcal/100g'},
      {'name': '覆盆子', 'tag': '酸甜', 'kcal': '52kcal/100g'},
      {'name': '黑莓', 'tag': '高纤', 'kcal': '43kcal/100g'},
    ],
    '热带水果': [
      {'name': '牛油果', 'tag': '脂肪', 'kcal': '160kcal/100g'},
      {'name': '芒果', 'tag': '香甜', 'kcal': '60kcal/100g'},
      {'name': '菠萝', 'tag': '清爽', 'kcal': '50kcal/100g'},
      {'name': '香蕉', 'tag': '能量', 'kcal': '89kcal/100g'},
    ],
    '柑橘类': [
      {'name': '橙子', 'tag': '维C', 'kcal': '47kcal/100g'},
      {'name': '柠檬', 'tag': '酸', 'kcal': '29kcal/100g'},
      {'name': '柚子', 'tag': '清新', 'kcal': '38kcal/100g'},
    ],
    '应季精选': [
      {'name': '苹果', 'tag': '常青', 'kcal': '52kcal/100g'},
      {'name': '梨', 'tag': '清甜', 'kcal': '57kcal/100g'},
      {'name': '葡萄', 'tag': '甜', 'kcal': '69kcal/100g'},
    ],
    '鱼虾贝': [
      {'name': '三文鱼', 'tag': '优质脂肪', 'kcal': '208kcal/100g'},
      {'name': '虾', 'tag': '高蛋白', 'kcal': '99kcal/100g'},
      {'name': '扇贝', 'tag': '鲜', 'kcal': '90kcal/100g'},
    ],
    '禽肉': [
      {'name': '鸡胸肉', 'tag': '高蛋白', 'kcal': '165kcal/100g'},
      {'name': '鸭胸肉', 'tag': '饱腹', 'kcal': '201kcal/100g'},
    ],
    '蛋奶': [
      {'name': '鸡蛋', 'tag': '百搭', 'kcal': '143kcal/100g'},
      {'name': '酸奶', 'tag': '顺口', 'kcal': '59kcal/100g'},
      {'name': '奶酪', 'tag': '浓郁', 'kcal': '402kcal/100g'},
    ],
    '豆制品': [
      {'name': '北豆腐', 'tag': '嫩', 'kcal': '76kcal/100g'},
      {'name': '毛豆', 'tag': '高纤', 'kcal': '122kcal/100g'},
      {'name': '豆浆', 'tag': '顺滑', 'kcal': '33kcal/100g'},
    ],
    '米面': [
      {'name': '面条', 'tag': '快手', 'kcal': '138kcal/100g'},
      {'name': '米饭', 'tag': '家常', 'kcal': '130kcal/100g'},
      {'name': '米粉', 'tag': '软糯', 'kcal': '109kcal/100g'},
    ],
    '全谷物': [
      {'name': '燕麦', 'tag': '耐饿', 'kcal': '389kcal/100g'},
      {'name': '糙米', 'tag': '饱腹', 'kcal': '370kcal/100g'},
      {'name': '藜麦', 'tag': '轻食', 'kcal': '368kcal/100g'},
    ],
    '薯类': [
      {'name': '土豆', 'tag': '百搭', 'kcal': '77kcal/100g'},
      {'name': '红薯', 'tag': '甜', 'kcal': '86kcal/100g'},
    ],
    '面包': [
      {'name': '吐司', 'tag': '快手', 'kcal': '265kcal/100g'},
      {'name': '全麦面包', 'tag': '饱腹', 'kcal': '247kcal/100g'},
    ],
    '叶菜': [
      {'name': '生菜', 'tag': '清爽', 'kcal': '15kcal/100g'},
      {'name': '菠菜', 'tag': '铁', 'kcal': '23kcal/100g'},
    ],
    '瓜茄': [
      {'name': '番茄', 'tag': '酸甜', 'kcal': '18kcal/100g'},
      {'name': '黄瓜', 'tag': '清爽', 'kcal': '15kcal/100g'},
      {'name': '茄子', 'tag': '绵', 'kcal': '25kcal/100g'},
    ],
    '菌菇': [
      {'name': '香菇', 'tag': '鲜', 'kcal': '34kcal/100g'},
      {'name': '金针菇', 'tag': '脆', 'kcal': '37kcal/100g'},
    ],
    '根茎': [
      {'name': '胡萝卜', 'tag': '胡萝卜素', 'kcal': '41kcal/100g'},
      {'name': '白萝卜', 'tag': '清甜', 'kcal': '18kcal/100g'},
    ],
    '坚果': [
      {'name': '杏仁', 'tag': '香', 'kcal': '579kcal/100g'},
      {'name': '核桃', 'tag': '脆', 'kcal': '654kcal/100g'},
      {'name': '腰果', 'tag': '甜香', 'kcal': '553kcal/100g'},
    ],
    '酸奶杯': [
      {'name': '原味酸奶', 'tag': '顺口', 'kcal': '59kcal/100g'},
      {'name': '格兰诺拉', 'tag': '脆', 'kcal': '471kcal/100g'},
      {'name': '香蕉片', 'tag': '甜', 'kcal': '89kcal/100g'},
    ],
    '低糖甜点': [
      {'name': '奇亚籽布丁', 'tag': '饱腹', 'kcal': '—'},
      {'name': '无糖果冻', 'tag': '轻', 'kcal': '—'},
    ],
    '小食': [
      {'name': '海苔', 'tag': '咸香', 'kcal': '—'},
      {'name': '玉米片', 'tag': '脆', 'kcal': '—'},
    ],
  };

  static final planSchedules = {
    '轻盈控卡': [
      PlanDaySchedule(
        breakfastTitle: '酸奶水果杯',
        breakfastDesc: '酸奶 + 莓果 + 燕麦',
        lunchTitle: '香煎鸡胸沙拉',
        lunchDesc: '鸡胸 + 生菜 + 番茄',
        dinnerTitle: '番茄鸡蛋面',
        dinnerDesc: '番茄 + 鸡蛋 + 面条',
      ),
      PlanDaySchedule(
        breakfastTitle: '燕麦香蕉杯',
        breakfastDesc: '燕麦 + 香蕉 + 坚果',
        lunchTitle: '清蒸鱼配蔬菜',
        lunchDesc: '鱼类 + 绿叶菜',
        dinnerTitle: '菌菇豆腐汤',
        dinnerDesc: '豆腐 + 菌菇 + 青菜',
      ),
    ],
    '元气增肌': [
      PlanDaySchedule(
        breakfastTitle: '鸡蛋吐司',
        breakfastDesc: '鸡蛋 + 全麦吐司',
        lunchTitle: '牛肉饭',
        lunchDesc: '牛肉 + 米饭 + 蔬菜',
        dinnerTitle: '三文鱼沙拉',
        dinnerDesc: '三文鱼 + 蔬菜',
      ),
    ],
    '清淡养胃': [
      PlanDaySchedule(
        breakfastTitle: '小米粥',
        breakfastDesc: '小米 + 温热',
        lunchTitle: '蒸蛋',
        lunchDesc: '鸡蛋 + 温水',
        dinnerTitle: '蔬菜面',
        dinnerDesc: '面条 + 软蔬菜',
      ),
    ],
  };
}
