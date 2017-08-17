import Ember from 'ember';
import { module, test } from 'qunit';
import findNearestProperty from 'tahi/lib/find-nearest-property';

module('FindNearestProperty');

let scenario = Ember.Object.create({isEditable: true});

function createScenario(scenario, level=1) {
  var parent = Ember.Object.create(scenario);
  for (var i = 1; i < level; i++) {
    parent = Ember.Object.create({parent: parent});
  }
  return parent;
}

test('immediate success', function(assert) {
  let parent = createScenario({scenario: scenario});
  let result = findNearestProperty(parent, 'scenario');
  assert.equal(result && result.isEditable, true, 'scenario on immediate object is found');
});

test('nested success', function(assert) {
  let parent = createScenario({scenario: scenario}, 3);
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result && result.isEditable, true, 'scenario on nested object is found');
});

test('immediate failure', function(assert) {
  let parent = createScenario({nonScenario: scenario});
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result, null, 'scenario on immediate object not found');
});

test('nested failure', function(assert) {
  let parent = createScenario({nonScenario: scenario}, 3);
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result, null, 'scenario on nested object not found');
});

