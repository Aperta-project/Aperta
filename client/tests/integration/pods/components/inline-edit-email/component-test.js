/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';

moduleForComponent('inline-edit-email', 'Integration | Component | inline edit email', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);
    this.set('emailSentStates', []);
    this.set('bodyPart', {} );
    let task = make('ad-hoc-task', {body: []});
    this.set('task', task);
    this.fake = this.container.lookup('service:can');
  }

});

let template = hbs`{{inline-edit-email
                          canEdit=canEdit
                          emailSentStates=emailSentStates
                          canManage=canManage
                          task=task}}`;

test('canManage=true, canEdit=false, can add email participants', function(assert){

  this.fake.allowPermission('add_email_participants', this.task);

  this.set('canEdit', true);
  this.set('canManage', false);
  this.render(template);

  assert.elementFound('.email-send-participants');
});

test('canManage=true, canEdit=false, can not add email participants', function(assert){
  this.set('canEdit', false);
  this.set('canManage', false);
  this.render(template);

  assert.elementNotFound('.email-send-participants');
});

test('can send email after selecting participants', function(assert){
  this.fake.allowPermission('add_email_participants', this.task);

  let sendEmail = function() { assert.ok(true); };
  let fakeUser = Ember.Object.create({
    id: 1,
    full_name: 'Test User',
    avatar_url: 'http://example.com/pic.jpg',
    email: 'test.user@example.com'});

  this.set('canEdit', true);
  this.set('canManage', false);
  this.set('recipients', [fakeUser]);
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
  assert.elementFound('.send-email-action');
  this.$('.send-email-action').click();

  assert.elementFound('.bodypart-last-sent',
                      'The sent at time should appear');
  assert.elementFound('.bodypart-email-sent-overlay',
                      'The sent confirmation should appear');
});

test('can remove participants from email', function(assert){
  assert.expect(5);

  this.fake.allowPermission('add_email_participants', this.task);

  let fakeUsers = [
    Ember.Object.create({
      id: 1,
      fullName: 'Test User',
      email: 'test.user@example.com'
    }),
    Ember.Object.create({
      id: 2,
      fullName: 'Test User2',
      email: 'test.user2@example.com'
    })
  ];

  this.set('canEdit', true);
  this.set('canManage', false);
  this.set('recipients', fakeUsers);

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

  assert.nElementsFound('.participant-selector-user-name', 2, '2 recipients are rendered');
  this.$('.participant-selector-user-remove').first().click();
  assert.nElementsFound('.participant-selector-user-name', 1, 'selected recipient is removed from the DOM');

  assert.elementFound('.send-email-action');
  this.$('.send-email-action').click();
});
