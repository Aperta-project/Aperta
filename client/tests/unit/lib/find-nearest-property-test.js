import Ember from 'ember';
import { module, test } from 'qunit';
import findNearestProperty from 'tahi/lib/find-nearest-property';

module('FindNearestProperty');

let scenario = Ember.Object.create({isEditable: true});

test('immediate case', function(assert) {
  let parent = Ember.Object.create({scenario: scenario});
  let result = findNearestProperty(parent, 'scenario');
  assert.equal(result && result.isEditable, true, 'scenario on immediate object is found');
});

test('inherited case', function(assert) {
  var parent = Ember.Object.create({scenario: scenario});
  for (var i = 0; i < 3; i++) {
    parent = Ember.Object.create({parent: parent});
  }
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result && result.isEditable, true, 'scenario on inherited object is found');
});

test('failure case', function(assert) {
  var parent = Ember.Object.create({nonScenario: scenario});
  let result = findNearestProperty(parent, 'scenario', 'parent');
  assert.equal(result, null, 'scenario on inherited object not found');
});

