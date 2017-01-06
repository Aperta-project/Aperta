import DecisionOwnerMixin from 'tahi/mixins/decision-owner';
import Ember from 'ember';
import startApp from 'tahi/tests/helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import { make } from 'ember-data-factory-guy';
import { module, test } from 'qunit';

const DecisionOwnerObject = Ember.Object.extend(DecisionOwnerMixin);

module('Unit | Mixin | decision owner',{
  beforeEach() {
    this.App = startApp();
    return TestHelper.setup(this.App);
  },

  afterEach() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(this.App, 'destroy');
  }
});

test('decisionsAscending with many decisions, including a draft decision', function(assert) {
  const decisionOwner = DecisionOwnerObject.create({
    decisions: [
      make('decision', { majorVersion: 1, minorVersion: 0, draft: false}),
      make('decision', { majorVersion: 0, minorVersion: 0, draft: false}),
      make('decision', { majorVersion: 0, minorVersion: 1, draft: false}),
      make('decision', { majorVersion: null, minorVersion: null, draft: true}),
      make('decision', { majorVersion: 1, minorVersion: 1, draft: false})
    ]
  });
  const versions = decisionOwner.get('decisionsAscending').map(function(decision) {
    return decision.getProperties('minorVersion', 'majorVersion', 'draft');
  });
  const expectedVersions = [
    { majorVersion: 0, minorVersion: 0, draft: false},
    { majorVersion: 0, minorVersion: 1, draft: false},
    { majorVersion: 1, minorVersion: 0, draft: false},
    { majorVersion: 1, minorVersion: 1, draft: false},
    { majorVersion: null, minorVersion: null, draft: true}
  ];
  assert.deepEqual(versions, expectedVersions);
});

test('latestDecision when there are two decisions', function(assert) {
  const decisionOwner = DecisionOwnerObject.create({
    decisions: [
      make('decision', { majorVersion: 1, minorVersion: 0, draft: false}),
      make('decision', { majorVersion: 0, minorVersion: 0, draft: false})
    ]
  });
  const version = decisionOwner.get('latestDecision').getProperties('majorVersion', 'minorVersion', 'draft');
  const expectedVersion = { majorVersion: 1, minorVersion: 0, draft: false };
  assert.deepEqual(version, expectedVersion);
});

test('latestDecision when there are zero decisions', function(assert) {
  const decisionOwner = DecisionOwnerObject.create({
    decisions: []
  });
  assert.equal(decisionOwner.get('latestDecision'), null);
});

test('latestDecision when version numbers change', function(assert) {
  const decisionOwner = DecisionOwnerObject.create({
    decisions: [
      make('decision', {majorVersion: 1, minorVersion: 0, draft: false}),
      make('decision', {majorVersion: 0, minorVersion: 0, draft: false})
    ]
  });
  const version = decisionOwner.get('latestDecision').getProperties('majorVersion', 'minorVersion', 'draft');
  const expectedVersion = { majorVersion: 1, minorVersion: 0, draft: false };
  assert.deepEqual(version, expectedVersion);

  // now change the majorVersion of the 0.0 decision so it becomes the latest
  Ember.run( () => {
    decisionOwner.get('decisions.lastObject').set('majorVersion', 2);
  });
  const mutatedVersion = decisionOwner.get('latestDecision')
    .getProperties('majorVersion', 'minorVersion', 'draft');
  const expectedMutatedVersion = { majorVersion: 2, minorVersion: 0, draft: false };
  assert.deepEqual(mutatedVersion, expectedMutatedVersion);
});
