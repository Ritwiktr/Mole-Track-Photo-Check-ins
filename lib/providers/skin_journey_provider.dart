import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/ai_config.dart';
import '../config/store_config.dart';
import '../services/local_storage.dart';
import '../services/openrouter_service.dart';

class RoutineStep {
  const RoutineStep({
    required this.id,
    required this.category,
    required this.productName,
    required this.blurb,
    this.emoji = '🧴',
  });

  final String id;
  final String category;
  final String productName;
  final String blurb;
  final String emoji;
}

class DailyHabit {
  const DailyHabit({required this.id, required this.title, required this.emoji});

  final String id;
  final String title;
  final String emoji;
}

class NutritionItem {
  const NutritionItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.tags,
  });

  final String id;
  final String name;
  final String amount;
  final List<String> tags;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'amount': amount, 'tags': tags};

  factory NutritionItem.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    return NutritionItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      tags: tagsRaw is List
          ? tagsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.products = const [],
  });

  final String text;
  final bool isUser;
  final List<MockProduct> products;
}

class MockProduct {
  const MockProduct({
    required this.brand,
    required this.name,
    required this.hint,
  });

  final String brand;
  final String name;
  final String hint;
}

class MolePhotoAnalysisEntry {
  const MolePhotoAnalysisEntry({
    required this.id,
    required this.imagePath,
    required this.analysis,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String analysis;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'analysis': analysis,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MolePhotoAnalysisEntry.fromJson(Map<String, dynamic> json) {
    return MolePhotoAnalysisEntry(
      id: json['id']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      analysis: json['analysis']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class MoleJourneyNotifier extends ChangeNotifier {
  static const String monthlyProductId = StoreConfig.monthlyProductId;
  static const String yearlyProductId = StoreConfig.yearlyProductId;
  static const String lifetimeProductId = StoreConfig.lifetimeProductId;
  static const Set<String> premiumProductIds = StoreConfig.premiumProductIds;

  MoleJourneyNotifier(this._storage) {
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (_) {},
    );
    _load();
  }

  final LocalStorage _storage;
  final OpenRouterService _openRouter = OpenRouterService();
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool chatAwaitingReply = false;
  bool photoAnalysisLoading = false;
  bool aiInsightsLoading = false;
  String? lastPhotoAnalysis;

  bool get onboardingComplete => _storage.onboardingComplete;

  Map<String, dynamic> answers = {};
  final Map<String, Set<String>> _routineChecked = {'morning': {}, 'night': {}};
  DateTime selectedDaily = DateTime.now();
  Map<String, bool> _dailyTasks = {};
  List<String> _progressPhotoPaths = [];
  List<MolePhotoAnalysisEntry> _photoAnalysisHistory = [];
  bool _darkModeEnabled = false;
  bool hydrated = false;
  bool _isPremium = false;
  String _activePremiumProductId = '';
  bool _storeAvailable = false;
  bool _purchaseLoading = false;
  String? _purchaseError;
  List<int> _uploadTimestamps = [];
  final Map<String, ProductDetails> _productDetailsById = {};

  final List<ChatMessage> chat = [];
  List<RoutineStep> _morningSteps = const [];
  List<RoutineStep> _nightSteps = const [];
  List<DailyHabit> _dailyHabits = const [];
  List<NutritionItem> _nutritionItems = const [];
  String _mainCause = '—';
  String _molePatternLabel = '—';
  double _monitoringPercent = 0;
  int _nextCheckInDaysEstimate = 0;
  double _improvementGoalFraction = 0;
  int _moleWatchScore = 0;

  Future<void> _load() async {
    answers = Map.from(_storage.answers);
    _routineChecked['morning'] = _storage.getRoutineChecked('morning');
    _routineChecked['night'] = _storage.getRoutineChecked('night');
    _progressPhotoPaths = _storage.progressPhotos;
    _photoAnalysisHistory = _storage.photoAnalysisHistory
        .map(MolePhotoAnalysisEntry.fromJson)
        .where((e) => e.id.isNotEmpty)
        .toList();
    _darkModeEnabled = _storage.darkModeEnabled;
    _isPremium = _storage.premiumActive;
    _activePremiumProductId = _storage.activePremiumProductId;
    _uploadTimestamps = _storage.uploadTimestamps;
    _applyAiContent(_storage.aiGeneratedContent);
    await _bootstrapPurchases();
    await _refreshAiContentIfPossible();
    _loadDay(selectedDaily);
    hydrated = true;
    notifyListeners();
  }

  void _loadDay(DateTime day) {
    final stored = _storage.dailyTasksFor(day);
    _dailyTasks = {for (final h in _dailyHabits) h.id: stored[h.id] ?? false};
  }

  bool isStepDone(String period, String id) =>
      _routineChecked[period]?.contains(id) ?? false;

  Future<void> toggleRoutine(String period, String id) async {
    final set = _routineChecked.putIfAbsent(period, () => {});
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await _storage.saveRoutineChecked(period, set);
    notifyListeners();
  }

  void pickDailyDay(DateTime day) {
    selectedDaily = DateTime(day.year, day.month, day.day);
    _loadDay(selectedDaily);
    notifyListeners();
  }

  Future<void> toggleDaily(String id) async {
    _dailyTasks[id] = !(_dailyTasks[id] ?? false);
    await _storage.saveDailyTasks(selectedDaily, Map.from(_dailyTasks));
    notifyListeners();
  }

  int get dailyCompleted =>
      _dailyTasks.values.where((v) => v == true).length;

  int get dailyTotal => _dailyHabits.length;

  bool isDailyDone(String id) => _dailyTasks[id] ?? false;

  List<String> get progressPhotoPaths => List.unmodifiable(_progressPhotoPaths);
  List<MolePhotoAnalysisEntry> get photoAnalysisHistory =>
      List.unmodifiable(_photoAnalysisHistory);
  List<RoutineStep> get morningSteps => List.unmodifiable(_morningSteps);
  List<RoutineStep> get nightSteps => List.unmodifiable(_nightSteps);
  List<DailyHabit> get dailyHabits => List.unmodifiable(_dailyHabits);
  List<NutritionItem> get nutritionItems => List.unmodifiable(_nutritionItems);
  bool get darkModeEnabled => _darkModeEnabled;
  bool get isPremium => _isPremium;
  bool get purchaseLoading => _purchaseLoading;
  String? get purchaseError => _purchaseError;
  bool get storeAvailable => _storeAvailable;
  String get activePremiumProductId => _activePremiumProductId;
  List<ProductDetails> get premiumProducts => premiumProductIds
      .map((id) => _productDetailsById[id])
      .whereType<ProductDetails>()
      .toList(growable: false);

  Future<void> setDarkMode(bool enabled) async {
    _darkModeEnabled = enabled;
    await _storage.setDarkModeEnabled(enabled);
    notifyListeners();
  }

  Future<void> addProgressPhotoPath(String path) async {
    if (path.trim().isEmpty) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _pruneUploadHistory(nowMs);
    if (!isPremium && _uploadTimestamps.isNotEmpty) {
      throw StateError('FREE_UPLOAD_LIMIT_REACHED');
    }
    final deduped = <String>{path, ..._progressPhotoPaths};
    _progressPhotoPaths = deduped.take(24).toList();
    _uploadTimestamps = [nowMs, ..._uploadTimestamps].take(24).toList();
    await _storage.saveProgressPhotos(_progressPhotoPaths);
    await _storage.saveUploadTimestamps(_uploadTimestamps);
    notifyListeners();
  }

  Future<void> removeProgressPhotoPath(String path) async {
    _progressPhotoPaths.remove(path);
    await _storage.saveProgressPhotos(_progressPhotoPaths);
    notifyListeners();
  }

  Future<MolePhotoAnalysisEntry> analyzeMoleFromPhoto(String imagePath) async {
    photoAnalysisLoading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final fallbackEntry = MolePhotoAnalysisEntry(
        id: now.microsecondsSinceEpoch.toString(),
        imagePath: imagePath,
        analysis:
            'Photo analysis needs AI API setup first.\n\n'
            'Add OPENROUTER_API_KEY to your `.env` file, then try again.\n'
            'Once enabled, you will get mole-focused observations and weekly comparisons.',
        createdAt: now,
      );
      if (AiConfig.openRouterApiKey.isEmpty) {
        lastPhotoAnalysis = fallbackEntry.analysis;
        await _appendPhotoAnalysisEntry(fallbackEntry);
        return fallbackEntry;
      }

      final bytes = await File(imagePath).readAsBytes();
      final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final analysis = await _openRouter.molePhotoAnalysis(
        imageDataUrl: dataUrl,
        userContext: 'User profile JSON: ${jsonEncode(answers)}',
      );

      final entry = MolePhotoAnalysisEntry(
        id: now.microsecondsSinceEpoch.toString(),
        imagePath: imagePath,
        analysis: analysis,
        createdAt: now,
      );
      lastPhotoAnalysis = analysis;
      await _appendPhotoAnalysisEntry(entry);
      chat.add(const ChatMessage(
        text: 'I uploaded a photo for mole map-style analysis.',
        isUser: true,
      ));
      chat.add(ChatMessage(text: analysis, isUser: false));
      return entry;
    } catch (e) {
      final text = _formatChatError(e);
      final entry = MolePhotoAnalysisEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imagePath: imagePath,
        analysis: text,
        createdAt: DateTime.now(),
      );
      lastPhotoAnalysis = text;
      await _appendPhotoAnalysisEntry(entry);
      return entry;
    } finally {
      photoAnalysisLoading = false;
      notifyListeners();
    }
  }

  Future<void> _appendPhotoAnalysisEntry(MolePhotoAnalysisEntry entry) async {
    _photoAnalysisHistory = [entry, ..._photoAnalysisHistory]
        .where((e) => e.imagePath.trim().isNotEmpty)
        .take(30)
        .toList();
    await _storage.savePhotoAnalysisHistory(
      _photoAnalysisHistory.map((e) => e.toJson()).toList(),
    );
  }

  /// Lightweight streak: consecutive days (including today) with >= 50% habits.
  int get streakApprox {
    var streak = 0;
    var d = DateTime.now();
    while (true) {
      final tasks = _storage.dailyTasksFor(d);
      if (tasks.isEmpty) {
        if (_isSameDay(d, DateTime.now())) {
          final todayPct = dailyTotal == 0
              ? 0.0
              : dailyCompleted / dailyTotal;
          if (todayPct >= 0.5) {
            streak++;
          }
          break;
        }
        break;
      }
      final done = tasks.values.where((v) => v).length;
      final total = _dailyHabits.length;
      if (total == 0 || done / total < 0.5) break;
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> completeOnboarding(Map<String, dynamic> nextAnswers) async {
    answers = nextAnswers;
    await _storage.saveAnswers(nextAnswers);
    await _storage.setOnboardingComplete(true);
    _loadDay(selectedDaily);
    notifyListeners();
    unawaited(_refreshAiContentIfPossible(showLoading: true));
  }

  Future<void> sendChat(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || chatAwaitingReply) return;

    chat.add(ChatMessage(text: trimmed, isUser: true));

    if (AiConfig.openRouterApiKey.isEmpty) {
      _replyOfflineNoApiKey();
      notifyListeners();
      return;
    }

    chatAwaitingReply = true;
    notifyListeners();

    try {
      final system = _chatSystemPrompt();
      final payload = chat
          .map(
            (m) => <String, dynamic>{
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            },
          )
          .toList();

      final reply = await _openRouter.chatCompletion(
        systemPrompt: system,
        messages: payload,
      );
      chat.add(ChatMessage(text: reply, isUser: false));
    } catch (e, stack) {
      assert(() {
        debugPrint('OpenRouter: $e\n$stack');
        return true;
      }());
      chat.add(ChatMessage(text: _formatChatError(e), isUser: false));
    } finally {
      chatAwaitingReply = false;
      notifyListeners();
    }
  }

  void _replyOfflineNoApiKey() {
    chat.add(
      const ChatMessage(
        text:
            'Live AI is off because no API key was found.\n\n'
            'Add OPENROUTER_API_KEY to the project root `.env` file (copy '
            '`env.example` to `.env` and fill in your key), or run with:\n'
            'flutter run --dart-define=OPENROUTER_API_KEY=YOUR_KEY\n\n'
            'Never commit real keys. `.env` is listed in .gitignore.',
        isUser: false,
      ),
    );
  }

  String _formatChatError(Object e) {
    if (e is OpenRouterHttpException) {
      return 'Could not get a reply (${e.statusCode}). ${e.message}';
    }
    return 'Could not get a reply. Check your connection and try again.';
  }

  String _chatSystemPrompt() {
    final buffer = StringBuffer()
      ..writeln(
        'You are MoleTrack AI+, a supportive mole-monitoring coach inside a mobile app.',
      )
      ..writeln(
        'You are not a medical professional: do not diagnose skin cancer. '
        'Encourage in-person evaluation for any new, changing, asymmetric, '
        'multicolor, large, or bleeding lesions, or anything the user is unsure about.',
      )
      ..writeln(
        'Be concise and practical (short paragraphs or light bullets). '
        'Emphasize consistent photos, lighting, and ABCDE self-check habits. '
        'Reference the user profile when helpful.',
      )
      ..writeln('User onboarding questionnaire (JSON):')
      ..writeln(jsonEncode(answers));
    return buffer.toString();
  }

  Future<void> _refreshAiContentIfPossible({bool showLoading = false}) async {
    if (!onboardingComplete) return;
    if (AiConfig.openRouterApiKey.isEmpty) return;
    if (showLoading) {
      aiInsightsLoading = true;
      notifyListeners();
    }
    try {
      final generated = await _generateAiContentFromAi();
      if (generated.isEmpty) return;
      _applyAiContent(generated);
      await _storage.saveAiGeneratedContent(generated);
      notifyListeners();
    } catch (_) {
      // Keep previously cached AI content when refresh fails.
    } finally {
      if (showLoading) {
        aiInsightsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<Map<String, dynamic>> _generateAiContentFromAi() async {
    final response = await _openRouter.chatCompletion(
      systemPrompt:
          'You generate concise app content JSON for a mole-monitoring and sun-safety assistant. '
          'Return only valid JSON.',
      messages: [
        {
          'role': 'user',
          'content': '''
Generate personalized app content from this onboarding JSON:
${jsonEncode(answers)}

Return only JSON with keys:
homeInsights: {mainCause:string, molePatternLabel:string, monitoringPercent:number(0-100), nextCheckInDaysEstimate:number, improvementGoalFraction:number(0-1), moleWatchScore:number(0-100)}
dailyHabits: [{id:string,title:string,emoji:string}]
careRoutine: {morning:[{id,category,productName,blurb}], night:[{id,category,productName,blurb}]}
nutritionItems: [{id,name,amount,tags:string[]}]
chatSeed: {welcome:string, products:[{brand,name,hint}]}

Constraints:
- 6 to 10 dailyHabits focused on mole photo habits, sun protection, and self-checks
- 3 to 5 morning steps (SPF, gentle cleansing, documentation tips)
- 2 to 4 night steps (moisturizer, retinoid only if appropriate for the profile, photo reminders)
- 3 to 6 nutrition items that support skin resilience (antioxidants, omega-3s, hydration)
- Short practical text; never claim medical diagnosis.
'''
        }
      ],
    );
    return _extractJsonMap(response);
  }

  Map<String, dynamic> _extractJsonMap(String text) {
    final trimmed = text.trim();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final candidate = trimmed.substring(start, end + 1);
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  void _applyAiContent(Map<String, dynamic> map) {
    final home = map['homeInsights'];
    if (home is Map) {
      _mainCause = home['mainCause']?.toString().trim().isNotEmpty == true
          ? home['mainCause'].toString().trim()
          : _mainCause;
      final moleLbl = home['molePatternLabel']?.toString().trim();
      final legacyAcneLbl = home['acneTypeLabel']?.toString().trim();
      if (moleLbl != null && moleLbl.isNotEmpty) {
        _molePatternLabel = moleLbl;
      } else if (legacyAcneLbl != null && legacyAcneLbl.isNotEmpty) {
        _molePatternLabel = legacyAcneLbl;
      }
      final mon = home['monitoringPercent'] ?? home['healingPercent'];
      if (mon is num) {
        _monitoringPercent = mon.toDouble().clamp(0, 100);
      }
      final nextDays = home['nextCheckInDaysEstimate'] ?? home['clearSkinDaysEstimate'];
      if (nextDays is num) {
        _nextCheckInDaysEstimate = nextDays.toInt().clamp(1, 365);
      }
      final impFrac =
          home['improvementGoalFraction'] ?? home['clearanceGoalFraction'];
      if (impFrac is num) {
        _improvementGoalFraction = impFrac.toDouble().clamp(0.0, 1.0);
      }
      final watch = home['moleWatchScore'] ?? home['acneScore'];
      if (watch is num) {
        _moleWatchScore = watch.toInt().clamp(0, 100);
      }
    }

    final habitsRaw = map['dailyHabits'];
    if (habitsRaw is List) {
      final parsed = habitsRaw
          .whereType<Map>()
          .map(
            (e) => DailyHabit(
              id: e['id']?.toString() ?? '',
              title: e['title']?.toString() ?? '',
              emoji: e['emoji']?.toString() ?? '',
            ),
          )
          .where((h) => h.id.isNotEmpty && h.title.isNotEmpty)
          .toList();
      if (parsed.isNotEmpty) _dailyHabits = parsed;
    }

    final routine = map['careRoutine'];
    if (routine is Map) {
      List<RoutineStep> parseSteps(dynamic raw) {
        if (raw is! List) return const [];
        return raw
            .whereType<Map>()
            .map(
              (e) => RoutineStep(
                id: e['id']?.toString() ?? '',
                category: e['category']?.toString() ?? '',
                productName: e['productName']?.toString() ?? '',
                blurb: e['blurb']?.toString() ?? '',
              ),
            )
            .where((s) => s.id.isNotEmpty && s.productName.isNotEmpty)
            .toList();
      }

      final morning = parseSteps(routine['morning']);
      final night = parseSteps(routine['night']);
      if (morning.isNotEmpty) _morningSteps = morning;
      if (night.isNotEmpty) _nightSteps = night;
    }

    final nutritionRaw = map['nutritionItems'];
    if (nutritionRaw is List) {
      final parsed = nutritionRaw
          .whereType<Map>()
          .map((e) => NutritionItem.fromJson(Map<String, dynamic>.from(e)))
          .where((n) => n.id.isNotEmpty && n.name.isNotEmpty)
          .toList();
      if (parsed.isNotEmpty) _nutritionItems = parsed;
    }

    final chatSeed = map['chatSeed'];
    if (chatSeed is Map) {
      final welcome = chatSeed['welcome']?.toString().trim() ?? '';
      final productsRaw = chatSeed['products'];
      final products = productsRaw is List
          ? productsRaw
              .whereType<Map>()
              .map(
                (e) => MockProduct(
                  brand: e['brand']?.toString() ?? '',
                  name: e['name']?.toString() ?? '',
                  hint: e['hint']?.toString() ?? '',
                ),
              )
              .where((p) => p.name.isNotEmpty)
              .toList()
          : const <MockProduct>[];
      if (welcome.isNotEmpty && chat.isEmpty) {
        chat.add(ChatMessage(text: welcome, isUser: false, products: products));
      }
    }
  }

  String get mainCause {
    if (!isPremium) return 'Upgrade to Premium';
    return _mainCause;
  }

  String get molePatternLabel {
    if (!isPremium) return 'Premium only';
    return _molePatternLabel;
  }

  double get monitoringPercent {
    if (!isPremium) return 0;
    return _monitoringPercent;
  }

  int get moleWatchScore {
    if (!isPremium) return 0;
    return _moleWatchScore;
  }

  int get nextCheckInDaysEstimate {
    if (!isPremium) return 0;
    return _nextCheckInDaysEstimate;
  }

  double get improvementGoalFraction {
    if (!isPremium) return 0;
    return _improvementGoalFraction;
  }

  List<bool> weekCompletionPreview() {
    final now = DateTime.now();
    return List<bool>.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final tasks = _storage.dailyTasksFor(day);
      if (tasks.isEmpty) {
        return i == 6 && dailyCompleted >= dailyTotal * 0.5;
      }
      final done = tasks.values.where((v) => v).length;
      return _dailyHabits.isNotEmpty && done >= _dailyHabits.length * 0.5;
    });
  }

  Future<void> _bootstrapPurchases() async {
    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      return;
    }
    final response = await _iap.queryProductDetails(premiumProductIds);
    if (response.error != null) {
      _purchaseError = response.error!.message;
    }
    for (final product in response.productDetails) {
      _productDetailsById[product.id] = product;
    }
    await _iap.restorePurchases();
  }

  Future<bool> buyPremium(String productId) async {
    _purchaseError = null;
    if (!_storeAvailable) {
      _purchaseError = 'Store is not available on this device.';
      notifyListeners();
      return false;
    }
    final product = _productDetailsById[productId];
    if (product == null) {
      _purchaseError = 'This plan is not available right now.';
      notifyListeners();
      return false;
    }
    _purchaseLoading = true;
    notifyListeners();
    final purchaseParam = PurchaseParam(productDetails: product);
    final isLifetime = productId == lifetimeProductId;
    final ok = isLifetime
        ? await _iap.buyNonConsumable(purchaseParam: purchaseParam)
        : await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    if (!ok) {
      _purchaseLoading = false;
      _purchaseError = 'Unable to start purchase. Please try again.';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> restorePurchases() async {
    _purchaseError = null;
    if (!_storeAvailable) {
      _purchaseError = 'Store is not available on this device.';
      notifyListeners();
      return;
    }
    _purchaseLoading = true;
    notifyListeners();
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    var changed = false;
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (premiumProductIds.contains(purchase.productID)) {
          _isPremium = true;
          _activePremiumProductId = purchase.productID;
          changed = true;
          unawaited(_storage.setPremiumActive(true));
          unawaited(_storage.setActivePremiumProductId(purchase.productID));
        }
      } else if (purchase.status == PurchaseStatus.error) {
        _purchaseError = purchase.error?.message ?? 'Purchase failed.';
        changed = true;
      } else if (purchase.status == PurchaseStatus.canceled) {
        _purchaseError = 'Purchase canceled.';
        changed = true;
      }

      if (purchase.pendingCompletePurchase) {
        unawaited(_iap.completePurchase(purchase));
      }
    }
    if (_purchaseLoading) {
      _purchaseLoading = false;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void _pruneUploadHistory(int nowMs) {
    const weekMs = 7 * 24 * 60 * 60 * 1000;
    _uploadTimestamps = _uploadTimestamps
        .where((ts) => nowMs - ts < weekMs)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
