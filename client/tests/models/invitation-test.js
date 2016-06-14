import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import customAssertions from '../helpers/custom-assertions';
import sinon from 'sinon';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app;
moduleForModel('invitation', 'Unit | Model | invitation', {
  needs: ['model:invitation'],
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

  let invitation = FactoryGuy.make('invitation');

  invitation.set('restless', fakeRestless);

  invitation.rescind();
  assert.spyCalledWith(fakeRestless.put,
    [`/api/invitations/${invitation.id}/rescind`],
    'Calls restless with rescind endpoint');
});
