import {moduleForComponent, test} from 'ember-qunit';
import startApp from '../helpers/start-app';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
// Pretend like you're in client/tests
import FakeCanService from '../helpers/fake-can-service';


var app, sandbox;

moduleForComponent(
  'paper-reviewer-task',
  'Integration | Components | Tasks | Invite Reviewer', {
  integration: true,
  setup: function() {
    app = startApp();
  },

  teardown: function() {
    return Ember.run(app, app.destroy);
  }
});


test('User can add a new reviewer after tweaking the email of an exiting user',
  function(assert){
    assert.expect(2);

    stubAutocompleteUser({
      id: 30,
      full_name: 'Foo Magoo',
      email: 'foo@example.com'
    }, this);

    stubStoreCreateRecord((type, properties) => {
      assert.equal(type, 'invitation', 'Creates a new invitation');
      assert.equal(
        properties.email, 'Foo Magoo <foo@example.com>',
        'Has a well-formatted email');
      return newInvitation();
    }, this);

    setupEditableTask(this);

    fillIn('#invitation-recipient', 'foo');
    click('.auto-suggest-item');

    // Tweak the existing email, as per scenario in APERTA-6811
    andThen(function() {
      let current = this.$('#invitation-recipient').val();
      this.$('#invitation-recipient').val(current).keyup();
    });

    click('.compose-invite-button');
    click('.invite-reviewer-button');
  }
);



var newInvitation = function(email) {
  return {
    state: 'pending',
    email: email,
    body: 'Hello',
    save() { return { then() {} }; }
  };
};

var newTask = function() {
  return {
    id: 2,
    title: 'Paper Reviewer',
    type: 'TahiStandardTasks::PaperReviewerTask',
    completed: false,
    isMetadataTask: false,
    isSubmissionTask: false,
    assignedToMe: false,
    invitationTemplate: {
      salutation: 'Hi!',
      body: 'You are invited!'
    },
    invitations: [

    ],
    decisions: [
      {id: 2, isLatest: true}
    ]
  };
};

var stubStoreCreateRecord = function(fn, context) {
  context.register('service:store', Ember.Object.extend({
    createRecord: fn
  }));
};

var stubAutocompleteUser = function(returnVal, context) {
  context.register('service:restless', Ember.Service.extend({
    get() {
      return new Ember.RSVP.Promise(function(resolve) {
        resolve({users:[returnVal]});
      });
    }
  }));
  context.inject.service('restless', { as: 'restless' });
};

var template = hbs`{{paper-reviewer-task task=task can=can container=container}}`;

var setupEditableTask = function(context, task) {
  task = task || newTask();
  var can = FakeCanService.create();
  can.allowPermission('edit', task);

  context.setProperties({
    can: can,
    task: task
  });

  context.render(template);
};
