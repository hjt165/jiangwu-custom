/// 插件管理器
/// 提供插件注册、初始化、生命周期管理

/// 插件基类
/// 所有插件必须继承此类并实现抽象方法
abstract class Plugin {
  /// 插件唯一标识
  String get id;

  /// 插件名称
  String get name;

  /// 插件版本
  String get version;

  /// 插件是否启用
  bool get isEnabled => true;

  /// 初始化插件
  Future<void> onInit();

  /// 启用插件
  Future<void> onEnable();

  /// 禁用插件
  Future<void> onDisable();

  /// 销毁插件
  Future<void> onDestroy();
}

/// 插件管理器
/// 管理所有插件的生命周期
class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  factory PluginManager() => _instance;
  PluginManager._internal();

  final Map<String, Plugin> _plugins = {};
  final Map<String, bool> _pluginStates = {};

  /// 注册插件
  void register(Plugin plugin) {
    if (_plugins.containsKey(plugin.id)) {
      print('插件已存在: ${plugin.id}');
      return;
    }
    _plugins[plugin.id] = plugin;
    _pluginStates[plugin.id] = plugin.isEnabled;
    print('插件已注册: ${plugin.name} (${plugin.id})');
  }

  /// 批量注册插件
  void registerAll(List<Plugin> plugins) {
    for (final plugin in plugins) {
      register(plugin);
    }
  }

  /// 初始化所有插件
  Future<void> initAll() async {
    for (final plugin in _plugins.values) {
      if (_pluginStates[plugin.id] == true) {
        try {
          await plugin.onInit();
          print('插件初始化成功: ${plugin.name}');
        } catch (e) {
          print('插件初始化失败: ${plugin.name} - $e');
        }
      }
    }
  }

  /// 启用插件
  Future<void> enablePlugin(String pluginId) async {
    final plugin = _plugins[pluginId];
    if (plugin == null) {
      print('插件不存在: $pluginId');
      return;
    }

    if (_pluginStates[pluginId] == true) {
      print('插件已启用: $pluginId');
      return;
    }

    try {
      await plugin.onEnable();
      _pluginStates[pluginId] = true;
      print('插件已启用: ${plugin.name}');
    } catch (e) {
      print('插件启用失败: ${plugin.name} - $e');
    }
  }

  /// 禁用插件
  Future<void> disablePlugin(String pluginId) async {
    final plugin = _plugins[pluginId];
    if (plugin == null) {
      print('插件不存在: $pluginId');
      return;
    }

    if (_pluginStates[pluginId] == false) {
      print('插件已禁用: $pluginId');
      return;
    }

    try {
      await plugin.onDisable();
      _pluginStates[pluginId] = false;
      print('插件已禁用: ${plugin.name}');
    } catch (e) {
      print('插件禁用失败: ${plugin.name} - $e');
    }
  }

  /// 销毁所有插件
  Future<void> destroyAll() async {
    for (final plugin in _plugins.values) {
      try {
        await plugin.onDestroy();
        print('插件已销毁: ${plugin.name}');
      } catch (e) {
        print('插件销毁失败: ${plugin.name} - $e');
      }
    }
    _plugins.clear();
    _pluginStates.clear();
  }

  /// 获取插件
  Plugin? getPlugin(String pluginId) {
    return _plugins[pluginId];
  }

  /// 获取所有已启用的插件
  List<Plugin> getEnabledPlugins() {
    return _plugins.values
        .where((p) => _pluginStates[p.id] == true)
        .toList();
  }

  /// 检查插件是否已注册
  bool hasPlugin(String pluginId) {
    return _plugins.containsKey(pluginId);
  }

  /// 检查插件是否已启用
  bool isPluginEnabled(String pluginId) {
    return _pluginStates[pluginId] ?? false;
  }
}
