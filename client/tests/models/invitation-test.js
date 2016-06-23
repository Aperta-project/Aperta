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

test('#declineFeedback sets declineReason and reviewerSuggestions to null,' +
     ' and pendingFeedback to false', function(assert) {
  var invitation = FactoryGuy.make('invitation', {
    declineReason: 'some reason',
    reviewerSuggestions: 'some people',
  });
  invitation.pendingFeedback = true;

  assert.equal(invitation.get('declineReason'),
               'some reason',
               'invitation has reason entered to begin with');
  assert.equal(invitation.get('reviewerSuggestions'),
               'some people',
               'invitation has suggestions entered to begin with');
  assert.equal(invitation.get('pendingFeedback'),
               true,
               'invitation is pending feedback to begin with');
  Ember.run(()=>{
    invitation.declineFeedback();
    return invitation;
  });

  assert.equal(invitation.get('declineReason'),
               null,
               'invitation has decline reason nulled');
  assert.equal(invitation.get('reviewerSuggestions'),
               null,
               'invitation has reviewer suggestions nulled');
  assert.equal(invitation.get('pendingFeedback'),
               false,
               'invitation is not pending feedback');
 });

test('#feedbackSent sets pendingFeedback to false', function(assert) {
  var invitation = FactoryGuy.make('invitation');
  invitation.pendingFeedback = true;

  assert.equal(invitation.get('pendingFeedback'),
               true,
               'invitation is pending feedback to begin with');
  Ember.run(()=>{
    invitation.feedbackSent();
    return invitation;
  });

  assert.equal(invitation.get('pendingFeedback'),
               false,
               'invitation is not pending feedback');
});
