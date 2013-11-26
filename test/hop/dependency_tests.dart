library test.hop.dependencies;

import 'package:args/args.dart';
import 'package:hop/hop_core.dart';
import 'package:hop/src/hop_runner.dart';
import 'package:unittest/unittest.dart';
import '../test_util.dart';

void main() {

  test('simple dependency', () {

    var reg = new TaskRegistry();

    var counts = new Map<String, int>();

    reg.addTask('one', (ctx) {
      expect(counts, isEmpty);
      _increment(counts, 'one');
    });

    expect(reg.tasks, hasLength(1));

    reg.addTask('two', (ctx) {
      expect(counts, { 'one' : 1 });
      _increment(counts, 'two');
    }, dependencies: ['one']);

    return runRegistry(reg, ['two'])
      .then((RunResult rr) {
        expect(rr, RunResult.SUCCESS);
        expect(counts, {'one' : 1, 'two': 1 });
      });
  });

  test('dependencies with args', () {

    var reg = new TaskRegistry();

    var counts = new Map<String, int>();

    var log = new List();

    reg.addTask('one', _createTaskWithArgs((TaskContext ctx) {
      expect(ctx.arguments['trueFlag'], true);
      expect(ctx.arguments['option'], 'c');
      expect(counts, isEmpty);
      _increment(counts, 'one');
    }));

    expect(reg.tasks, hasLength(1));

    reg.addTask('two', _createTaskWithArgs((ctx) {
      expect(ctx.arguments['trueFlag'], true);
      expect(ctx.arguments['option'], 'c');
      expect(counts, { 'one' : 1 });
      _increment(counts, 'two');
    }), dependencies: ['one']);

    return runRegistry(reg, ['two'], printer: log.add)
      .then((RunResult rr) {
        expect(rr, RunResult.SUCCESS);
        expect(counts, {'one' : 1, 'two': 1 });

      })
      .catchError((_) {}, test: (error) {
        print(log.join('\n'));
        return false;
      });
  });

  // figure out dependency tree correctly

  // no duplicates

  // loops blow up

  // simple dependency

  // no null dependencies

}

Task _createTaskWithArgs(dynamic taskExec(TaskContext ctx)) {
  return new Task(taskExec, config: _parserConfig);
}

void _parserConfig(ArgParser parser) {
  parser.addFlag('trueFlag', defaultsTo: true);
  parser.addOption('option', allowed: ['a,b,c'], defaultsTo: 'c');
}

void _increment(Map<String, int> counts, String value) {
  int current = counts.putIfAbsent(value, () => 0);
  counts[value] = current + 1;
}
