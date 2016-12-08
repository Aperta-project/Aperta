import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';

moduleForComponent('inline-edit-email', 'Integration | Component | inline edit email', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
  }

});

let template = hbs`{{inline-edit-email
                          canEdit=canEdit
                          emailSentStates=emailSentStates
                          canManage=canManage
                          task=task}}`;

test('canManage=true, canEdit=false, can add email participants', function(assert){
  this.registry.register('service:can', FakeCanService);
  let task = make('ad-hoc-task', {body: []});

  let fake = this.container.lookup('service:can');
  fake.allowPermission('add_email_participants', task);

  this.set('emailSentStates', []);
  this.set('task', task);
  this.set('canEdit', false);
  this.set('canManage', false);
  this.render(template);

  assert.elementFound('.email-send-participants');
});

test('canManage=true, canEdit=false, can not add email participants', function(assert){
  this.registry.register('service:can', FakeCanService);
  let task = make('ad-hoc-task', {body: []});

  this.set('emailSentStates', []);
  this.set('task', task);
  this.set('canEdit', false);
  this.set('canManage', false);
  this.render(template);

  assert.elementNotFound('.email-send-participants');
});

test('can send email after selecting participants', function(assert){
  this.registry.register('service:can', FakeCanService);
  let task = make('ad-hoc-task', {body: []});

  let fake = this.container.lookup('service:can');
  fake.allowPermission('add_email_participants', task);

  let sendEmail = function() { assert.ok(true); };
  let fakeUser = { id: 1,
                   full_name: 'Test User',
                   avatar_url: 'http://example.com/pic.jpg',
                   email: 'test.user@example.com'};

  this.set('task', task);
  this.set('canEdit', true);
  this.set('canManage', false);
  this.set('recipients', [fakeUser]);
  this.set('sendEmail', sendEmail);
  this.set('bodyPart', {} );
  this.set('emailSentStates', []);

  let template = hbs`{{inline-edit-email
                            bodyPart=bodyPart
                            canEdit=canEdit
                            emailSentStates=emailSentStates
                            overlayParticipants=recipients
                            sendEmail=(action sendEmail)
                            canManage=canManage
                            task=task}}`;
  this.render(template);

  assert.elementFound('.email-send-participants');
  this.$('.email-send-participants').click();
  assert.elementFound('.send-email-action');
  this.$('.send-email-action').click();

  assert.elementFound('.bodypart-last-sent',
                      'The sent at time should appear');
  assert.elementFound('.bodypart-email-sent-overlay',
                      'The sent confirmation should appear');
});

test('can remove participants from email', function(assert){
  assert.expect(6);
  this.registry.register('service:can', FakeCanService);
  let task = make('ad-hoc-task', {body: []});

  let fake = this.container.lookup('service:can');
  fake.allowPermission('add_email_participants', task);

  let fakeUsers = [
    {
      id: 1,
      full_name: 'Test User',
      avatar_url: 'http://example.com/pic.jpg',
      email: 'test.user@example.com'
    },
    {
      id: 2,
      full_name: 'Test User2',
      avatar_url: 'http://example.com/pic.jpg',
      email: 'test.user2@example.com'
    }
  ];

  this.set('task', task);
  this.set('canEdit', true);
  this.set('canManage', false);
  this.set('recipients', fakeUsers);
  this.set('bodyPart', {} );
  this.set('emailSentStates', []);

  let sendEmail = function({recipients}) {
    assert.equal(recipients.length, 1, 'email is only sent to 1 recipient');
  };
  this.set('sendEmail', sendEmail);

  let template = hbs`{{inline-edit-email
                            bodyPart=bodyPart
                            canEdit=canEdit
                            emailSentStates=emailSentStates
                            overlayParticipants=recipients
                            sendEmail=(action sendEmail)
                            canManage=canManage
                            task=task}}`;
  this.render(template);
  assert.elementFound('.email-send-participants');
  this.$('.email-send-participants').click();

  assert.nElementsFound('.select2-search-choice', 2, '2 recipients are rendered');
  Ember.run(() => {
    this.$('.select2-search-choice-close').first().click();
  });
  assert.nElementsFound('.select2-search-choice', 1, 'selected recipient is removed from the DOM');
  assert.equal(this.get('recipients.length'), 1, 'removes the recipient from the list');

  assert.elementFound('.send-email-action');
  this.$('.send-email-action').click();


});
