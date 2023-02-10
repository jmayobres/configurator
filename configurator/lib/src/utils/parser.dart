import 'dart:convert';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/getter.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:yaml/yaml.dart';

class InvalidYamlException implements Exception {
  final dynamic message;

  InvalidYamlException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "InvalidYamlException";
    return "InvalidYamlException: $message";
  }
}

class YamlParser {
  static YamlConfiguration? tryParse(String? yamlString) {
    try {
      return fromYamlString(yamlString);
    } catch (e) {
      print(e);
    }
    return null;
  }

  static YamlConfiguration fromYamlString(String? yamlString) {
    // Convert to YamlDocument (with validation)
    final YamlDocument document = _validate(yamlString)!;

    // Get the root node
    final YamlNode rootNode = document.contents;

    final YamlNode configNode = rootNode.value['configuration'];
    final String id = rootNode.value['id'];
    final String? ns = rootNode.value['namespace'];

    var yamlConfig = YamlConfiguration(
      name: id,
      partFiles: _processParts(rootNode),
      weight: _processWeight(rootNode),
      flags: _processSettings(configNode, 'flags', ns),
      colors: _processSettings(configNode, 'colors', ns),
      images: _processSettings(configNode, 'images', ns),
      sizes: _processSettings(configNode, 'sizes', ns),
      padding: _processSettings(configNode, 'paddings', ns),
      margins: _processSettings(configNode, 'margins', ns),
      misc: _processSettings(configNode, 'misc', ns),
      textStyles: _processTextStyles(configNode, ns),
      routes: _processRoutes(configNode, 'routes'),
      strings: _processTranslations(configNode, 'strings', ns),
      i18n: _processTranslations(configNode, 'i18n', ns),
    );

    return yamlConfig;
  }

  static List<String> _processParts(YamlNode node) {
    List<String> parts = [];

    try {
      final partsNode = node.value['parts'];

      if (partsNode is! YamlList) {
        return parts;
      }

      for (var e in partsNode.value) {
        if (e is String) {
          parts.add(e);
        }
      }
    } catch (e) {
      print(e);
    }

    return parts;
  }

  static int _processWeight(YamlNode configNode) {
    try {
      final node = configNode.value['weight'];

      if (node is int) {
        return node;
      } else if (node is String) {
        return int.parse(node);
      }
    } catch (e) {
      print(e);
    }

    return 0;
  }

  static List<YamlTextStyle> _processTextStyles(YamlNode configNode,
      [String? namespace]) {
    List<YamlTextStyle> textStyles = [];

    var stylesNode = configNode.value['textStyles'];

    try {
      if (stylesNode is! YamlMap) {
        return textStyles;
      }

      var str = jsonEncode(stylesNode);

      Map<String, dynamic> map = json.decode(str);

      textStyles.addAll(_getTextStyleNamespaces(map, [], namespace ?? ''));
    } catch (e) {
      print(e);
    }

    return textStyles;
  }

  static List<YamlSetting> _processSettings(YamlNode configNode, String type,
      [String? namespace]) {
    List<YamlSetting> settings = [];

    try {
      final settingsNode = configNode.value[type];

      if (settingsNode is! YamlMap) {
        return settings;
      }

      var str = jsonEncode(settingsNode);

      Map<String, dynamic> map = json.decode(str);

      settings.addAll(_getSettingNamespaces(map, [], namespace ?? ''));
    } catch (e) {
      print(e);
    }

    return settings;
  }

  static List<YamlRoute> _processRoutes(YamlNode configNode, String type) {
    List<YamlRoute> routes = [];

    try {
      final settingsNode = configNode.value[type];

      if (settingsNode is! YamlList) {
        return routes;
      }

      var str = jsonEncode(settingsNode);

      List<dynamic> list = json.decode(str);

      for (var route in list) {
        var processed = YamlRoute.fromJson(route);

        routes.add(processed);

        for (var c in _getChildren(processed, [])) {
          routes.add(c);
        }
      }
    } catch (e) {
      print(e);
    }

    return routes;
  }

  static List<YamlSetting> _getSettingNamespaces(
      Map<String, dynamic> setting, List<YamlSetting> result, String path) {
    for (var es in setting.entries) {
      if (es.value is Map) {
        result.addAll(_getSettingNamespaces(es.value, [],
            '${path.capitalized}_${es.key.capitalized}'.canonicalize));
      } else {
        result.add(YamlSetting(
            '${path.capitalized}_${es.key.capitalized}'.canonicalize,
            es.value));
      }
    }

    return result;
  }

  static List<YamlTextStyle> _getTextStyleNamespaces(
      Map<String, dynamic> setting, List<YamlTextStyle> result, String path) {
    for (var es in setting.entries) {
      if (es.value is Map && !es.value.keys.contains('typeface')) {
        result.addAll(
          _getTextStyleNamespaces(
            es.value,
            [],
            '${path.capitalized}_${es.key.capitalized}'.canonicalize,
          ),
        );
      } else {
        result.add(
          YamlTextStyle(
            key: '${path.capitalized}_${es.key.capitalized}'.canonicalize,
            color: es.value['color'] ?? '000000',
            size: es.value['size'] ?? 12.0,
            weight: es.value['weight'] ?? 400,
            height: es.value['height'] ?? 0,
            typeface: <String, String>{
              ...es.value['typeface'],
            },
          ),
        );
      }
    }

    return result;
  }

  static List<YamlRoute> _getChildren(YamlRoute route, List<YamlRoute> result) {
    for (YamlRoute c in route.children) {
      result.add(c);

      if (c.children.isNotEmpty) {
        return _getChildren(c, result);
      }
    }

    return result;
  }

  static List<YamlI18n> processTranslationsMap(
      Map<String, dynamic> translationsMap) {
    List<YamlI18n> translations = [];

    try {
      for (var t in translationsMap.entries) {
        var values = t.value.entries.map((v) {
          return YamlI18n(v.key, t.key, v.value);
        });
        translations.addAll(List.from(values));
      }
    } catch (e) {
      print(e);
    }

    return translations;
  }

  static List<YamlI18n> _processTranslations(YamlNode configNode, String type,
      [String? namespace]) {
    List<YamlI18n> translations = [];

    try {
      final YamlNode translationsNode = configNode.value[type];

      if (translationsNode is! YamlMap) {
        return translations;
      }

      var str = jsonEncode(translationsNode);

      Map<String, dynamic> translationsMap = json.decode(str);

      if (translationsMap.isNotEmpty &&
          namespace != null &&
          namespace.isNotEmpty == true) {
        var namespaces = [
          translationsMap.keys.first,
          ...namespace.split('.'),
        ];

        Map<String, dynamic> result = translationsMap[namespaces.first];

        for (var i = 0; i < namespaces.length; i++) {
          var current = namespaces.reversed.toList()[i];

          result = {
            current: result,
          };
        }

        translationsMap = result;
      }

      for (var t in translationsMap.entries) {
        var values =
            t.value.entries.map((v) => YamlI18n(v.key, t.key, v.value));
        translations.addAll(List.from(values));
      }
    } catch (e) {
      print(e);
    }

    return translations;
  }

  static void _validateContents(YamlDocument document) {
    final YamlNode rootNode = document.contents;

    if (rootNode.value == null) {
      throw InvalidYamlException('rootNode value was null.');
    }

    if (rootNode.value == null || rootNode.value is! YamlMap) {
      throw InvalidYamlException(
          'rootNode.value was ${rootNode.value?.runtimeType}, expected YamlMap');
    }

    if (!(rootNode.value as YamlMap).containsKey('configuration')) {
      throw InvalidYamlException('No "configuration" key exists');
    } else if ((rootNode.value as YamlMap)['configuration'] is! YamlMap) {
      throw InvalidYamlException(
          'configuration.value was ${(rootNode.value as YamlMap)['configuration']?.runtimeType}, expected YamlMap');
    }

    if (!(rootNode.value as YamlMap).containsKey('id')) {
      throw InvalidYamlException('No "id" key exists');
    } else if ((rootNode.value as YamlMap)['id'] is! String) {
      throw InvalidYamlException(
          'Invalid ID specified. Must be non-empty value of type String');
    }
  }

  static YamlDocument? _validate(String? yamlString) {
    // First step validation (not empty or null)
    _inputValidate(yamlString);

    // Ensure the input can be decoded with convert.dart
    dynamic decoded = _decodeValidate(yamlString);

    // Ensure decoded value is not empty map
    _notEmptyMapValidate(decoded);

    // Ensure package:yaml is able to convert to YamlDocument
    YamlDocument document = _loadYamlValidate(yamlString!);

    // Ensure the contents of the document include the required fields.
    _validateContents(document);

    return document;
  }

  static YamlDocument _loadYamlValidate(String yamlString) {
    try {
      return loadYamlDocument(yamlString);
    } on Exception catch (e) {
      throw InvalidYamlException('Unable to loadYamlDocument: ${e.toString()}');
    }
  }

  static void _inputValidate(String? yamlString) {
    if (yamlString == null) {
      throw InvalidYamlException('input was null');
    }

    if (yamlString.isEmpty) {
      throw InvalidYamlException('input was empty');
    }
  }

  static dynamic _decodeValidate(String? yamlString) {
    try {
      return jsonDecode(jsonEncode(loadYamlNode(yamlString!)));
    } on Exception catch (e) {
      throw InvalidYamlException(
          'Unable to decode input into JSON: ${e.toString()}');
    }
  }

  static void _notEmptyMapValidate(dynamic x) {
    if (x is! Map || x.isEmpty) {
      throw InvalidYamlException(
          'Input was not decoded into a map. Was: ${x?.runtimeType}');
    } else if (x.isEmpty) {
      throw InvalidYamlException('Input was an empty map.');
    }
  }
}

class I18nParser {
  static Map<String, dynamic> parse({
    required List<YamlI18n> strings,
    void Function(Getter)? onGetter,
  }) {
    Map<String, dynamic> map = {};

    for (var f in strings) {
      map[f.locale] ??= {};
      map[f.locale][f.name] ??= f.value;
    }

    List<String> locales = map.keys.toList();

    Map<String, dynamic> result = {};

    var r = locales.map((e) {
      return visitTranslations(e, Map.from(map[e]), null, result, [], onGetter);
    }).reduce((value, element) => deepMapMerge(value, element));

    return r;
  }

  static void _translatePrimitive(
    String locale,
    dynamic input,
    dynamic parent,
    Map<String, dynamic> result,
    List<String> path,
    void Function(Getter)? onGetter,
  ) {
    if (input is! String && input is! num) {
      throw Exception(
          'Non-primitive type passed to _translatePrimitive: ${input.runtimeType}');
    }

    String valueKey = path.map((e) => e.capitalized).join('_').canonicalize;

    if (onGetter != null) {
      onGetter(Getter(valueKey, valueKey));
    }

    result[valueKey] = {
      locale: '$input',
    };
  }

  static void _translateMap(
    String locale,
    Map<dynamic, dynamic> input,
    dynamic parent,
    Map<String, dynamic> result,
    List<String> path,
    void Function(Getter)? onGetter,
  ) {
    for (var entry in input.entries) {
      var translations = visitTranslations(
        locale,
        entry.value,
        input,
        {},
        [
          ...(path.isNotEmpty ? [...path, '_'] : path),
          entry.key,
        ],
        onGetter,
      );

      result.addAll(
        translations,
      );
    }
  }

  static void _translateList(
    String locale,
    List<dynamic> input,
    dynamic parent,
    Map<String, dynamic> result,
    List<String> path,
    void Function(Getter)? onGetter,
  ) {
    Map<String, List<String>> primitives = {};

    String primaryKey = path.map((e) => e.capitalized).join('_').canonicalize;

    List<dynamic> builtKeys = [];

    List<Getter> childGetters = [];

    for (var i = 0; i < input.length; i++) {
      var entry = input[i];
      var newPath = [
        ...path,
        '_',
        '$i',
      ];

      var entryTranslations = visitTranslations(
        locale,
        entry,
        input,
        {},
        newPath,
        (getter) {
          childGetters.add(getter);

          if (onGetter != null) {
            onGetter(getter);
          }
        },
      );

      result.addAll(entryTranslations);

      builtKeys.addAll(entryTranslations.keys);

      if (entry is String || entry is num) {
        primitives[primaryKey] ??= [];
        primitives[primaryKey]!.addAll(entryTranslations.keys);
      } else if (entry is! Map<dynamic, dynamic>) {
        throw Exception('Encountered bad type while traversing translations: ${entry.runtimeType} - $entry');
      }
    }

    if (onGetter != null) {
      if (primitives.isNotEmpty) {
        onGetter(Getter(primaryKey, primitives[primaryKey]));
      }

      List<dynamic> rawObjectList = parent[path.last];

      List<Map<String, dynamic>> finalOutput = [];

      for (var i = 0; i < rawObjectList.length; i++) {
        Map<String, dynamic> mappedObject = {};

        var rawObject = rawObjectList[i];

        if (rawObject is! Map) {
          continue;
        }

        int rawObjectLen = 0;

        for (var entry in rawObject.entries) {
          if (entry.value is String || entry.value is num) {
            rawObjectLen++;
          } else if (entry.value is List) {
            rawObjectLen += (entry.value as List).length;
          }
        }

        var relKeys = builtKeys.sublist(0, rawObjectLen);
        builtKeys.removeRange(0, rawObjectLen);

        for (var x = 0; x < rawObjectLen; x++) {
          var entry = rawObject.entries.toList()[x];

          if (entry.value is List) {
            if (childGetters.isEmpty) {
              var key = entry.key;
              var value = [];
              for (var y = 0; y < entry.value.length; y++) {
                value.add(relKeys[x]);
                x++;
              }

              mappedObject[key] = value;
            } else {
              var key = entry.key;
              var value = childGetters.last.key;
              mappedObject[key] = value;
              x += (entry.value as List).length;
            }
          } else {
            var key = entry.key;
            var value = relKeys[x];
            mappedObject[key] = value;
          }
        }

        finalOutput.add(mappedObject);
      }

      onGetter(Getter(primaryKey, finalOutput));
    }
  }

  static Map<String, dynamic> visitTranslations(
    String locale,
    dynamic input,
    dynamic parent,
    Map<String, dynamic> result,
    List<String> path,
    void Function(Getter)? onGetter,
  ) {
    if (input is Map<dynamic, dynamic>) {
      _translateMap(locale, input, parent, result, path, onGetter);
    } else if (input is List) {
      _translateList(locale, input, parent, result, path, onGetter);
    } else if (input is String || input is num) {
      _translatePrimitive(locale, input, parent, result, path, onGetter);
    } else {
      throw Exception(
          'Unsupported setting found in Strings : ${input.runtimeType}');
    }

    return result;
  }

  static Map<String, dynamic> deepMapMerge(
    Map<String, dynamic> original,
    Map<String, dynamic> newMap,
  ) {
    for (var key in newMap.keys) {
      if (newMap[key] is Map && original[key] is Map) {
        original[key] = deepMapMerge(original[key], newMap[key]);
      } else {
        original[key] = newMap[key];
      }
    }

    return original;
  }
}
