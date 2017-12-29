import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import sinon from 'sinon';
import startApp from 'tahi/tests/helpers/start-app';
import * as TestHelper from 'ember-data-factory-guy';

var app;

moduleForModel('invitation', 'Unit | Model | invitation', {
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

test('rescind() and accept() use restless to touch endpoints', function(assert) {
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

  const data = { firstName: 'foo', lastName: 'bar'};
  invitation.accept(data);
  assert.spyCalledWith(fakeRestless.put,
    [`/api/invitations/${invitation.id}/accept`, {first_name: 'foo', last_name: 'bar'}],
    'Calls restless with accept endpoint');
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

test('academicEditor', function(assert) {
  const invitation = FactoryGuy.make('invitation', {inviteeRole: 'Academic Editor'});
  assert.ok(invitation.get('academicEditor'));
});

test('reviewer', function(assert) {
  const invitation = FactoryGuy.make('invitation', {inviteeRole: 'Reviewer'});
  assert.ok(invitation.get('reviewer'));
});
