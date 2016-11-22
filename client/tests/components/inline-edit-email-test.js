import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';

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
