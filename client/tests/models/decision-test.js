import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import customAssertions from '../helpers/custom-assertions';
import sinon from 'sinon';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app;
moduleForModel('decision', 'Unit | Model | decision', {
  needs: ['model:invitation', 'model:paper', 'model:nested-question-answer'],
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(app, 'destroy');
  },
  beforeEach: function() {
    app = startApp();
    return TestHelper.setup(app);
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
