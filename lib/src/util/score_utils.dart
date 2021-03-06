// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/lint/config.dart'; // ignore: implementation_imports
import 'package:http/http.dart' as http;

final _pedanticOptionsRootUrl =
    Uri.https('raw.githubusercontent.com', '/dart-lang/pedantic/master/lib/');
final _pedanticOptionsUrl =
    _pedanticOptionsRootUrl.resolve('analysis_options.yaml');

List<String>? _pedanticRules;

Future<List<String>> get pedanticRules async =>
    _pedanticRules ??= await _fetchPedanticRules();

Future<List<String>> fetchRules(Uri optionsUrl) async {
  var config = await _fetchConfig(optionsUrl);
  if (config == null) {
    print('no config found for: $optionsUrl (SKIPPED)');
    return <String>[];
  }
  var rules = <String>[];
  for (var ruleConfig in config.ruleConfigs) {
    var name = ruleConfig.name;
    if (name != null) {
      rules.add(name);
    }
  }
  return rules;
}

Future<LintConfig?> _fetchConfig(Uri url) async {
  print('loading $url...');
  var req = await http.get(url);
  return processAnalysisOptionsFile(req.body);
}

Future<List<String>> _fetchPedanticRules() async {
  print('loading $_pedanticOptionsUrl...');
  var req = await http.get(_pedanticOptionsUrl);
  var includedOptions = req.body.split('include: package:pedantic/')[1].trim();
  return fetchRules(_pedanticOptionsRootUrl.resolve(includedOptions));
}
