import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';
import { module, test } from 'qunit';

module('Unit: de-namespace-task-type');

test('deNamespaceTaskType denamespaces task types', function(assert) {
  var result;
  result = deNamespaceTaskType('Foo::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('deNamespaceTaskType doesnt touch unnamespaced stuff', function(assert) {
  var result;
  result = deNamespaceTaskType('Task');
  return assert.equal(result, 'Task', 'Task goes through unchanged');
});

test('deNamespaceTaskType denamespaces deeply namespaced task types', function(assert) {
  var result;
  result = deNamespaceTaskType('Foo::Baz::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('deNamespaceTaskType denamespaces really deeply namespaced task types', function(assert) {
  var result;
  result = deNamespaceTaskType('Tahi::Foo::Baz::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});
