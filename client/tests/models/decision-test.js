import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import customAssertions from '../helpers/custom-assertions';
import sinon from 'sinon';
import startApp from '../helpers/start-app';
import * as TestHelper from 'ember-data-factory-guy';

var app;
moduleForModel('decision', 'Unit | Model | decision', {
  integration: true,
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.mockTeardown();
    });
    return Ember.run(app, 'destroy');
  },
  beforeEach: function() {
    app = startApp();
    return TestHelper.mockSetup();
  }
});


test("rescind() uses restless to touch the rescind endpoint", function(assert) {
  let fakeRestless = {
    put: sinon.stub()
  };
  fakeRestless.put.returns({ then: () => {} });

  let decision = FactoryGuy.make('decision', {
    rescindable: true
  });

  decision.set('restless', fakeRestless);

  decision.rescind();
  assert.spyCalledWith(fakeRestless.put,
    [`/api/decisions/${decision.id}/rescind`],
    'Calls restless with rescind endpoint');
});

test('revisionNumber', function(assert) {
  const [majorVersion, minorVersion] = [1, 2];
  const decision = FactoryGuy.make('decision', {
    majorVersion,
    minorVersion
  });

  assert.equal(
    decision.get('revisionNumber'),
    `${majorVersion}.${minorVersion}`
  );
});

test('terminal', function(assert) {
  assert.ok(FactoryGuy.make('decision', { verdict: 'accept' }).get('terminal'));
  assert.ok(FactoryGuy.make('decision', { verdict: 'reject' }).get('terminal'));
  assert.notOk(FactoryGuy.make('decision', { verdict: 'major_revision' }).get('terminal'));
  assert.notOk(FactoryGuy.make('decision', { verdict: 'minor_revision' }).get('terminal'));
});
