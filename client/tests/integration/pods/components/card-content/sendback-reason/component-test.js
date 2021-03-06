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

import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('card-content/sendback-reason', 'Integration | Component | card content | sendback reason', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.set('actionStub', function() {});
    this.set('answerActionStub', function() {});
    this.set('owner', make('custom-card-task'));
    this.set('content', Ember.Object.create({ ident: 'test' }));
    this.set('answer', Ember.Object.create({ value: null }));
    this.set('answerChanged', null);
    this.set('preview', false);
    this.set('repetition', null);
    this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
  }
});

let createSendbackWithChildren = () => {
  let sendback = make('card-content', {
    contentType: 'sendback-reason'
  });
  make('card-content', {
    contentType: 'check-box',
    ident: 'reason',
    label: 'See me!',
    text: 'lalalala',
    valueType: 'boolean',
    parent: sendback
  });
  make('card-content', { // pencil
    contentType: 'check-box',
    valueType: 'boolean',
    parent: sendback
  });
  make('card-content', { // sendback reason textarea
    contentType: 'paragraph-input',
    ident: 'text-reason',
    parent: sendback
  });
  return sendback;
};

let template = hbs`{{card-content/sendback-reason
  content=sendback
  answer=answer
  disabled=disabled
  owner=owner
  repetition=repetition
  preview=preview
  answerChanged=answerChanged
  valueChanged=(action actionStub)}}`;

test('it shows its text if provided', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(template);

  assert.equal(this.$('.card-checkbox .card-form-text').text().trim(), 'lalalala');
});

test('it shows its label if provided', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(template);

  assert.equal(this.$('label').first().text().trim(), 'See me!');
});


test('it displays the pencil if sendback reason is checked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(template);

  this.$('input[type=checkbox]').click();
  assert.elementFound('.fa-pencil');

});

test('it hides the pencil if sendback reason is unchecked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(template);

  assert.elementNotFound('.fa-pencil');

});

test('it displays the textrea if sendback reason is checked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);
  this.set('preview', true);

  this.render(template);

  this.$('input[type=checkbox]').click();

  this.$('.fa-pencil').click();
  assert.elementFound('.card-content-paragraph-input');
});

test('it hides the textrea if sendback reason is checked but the pencil has not been clicked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);
  this.set('preview', true);

  this.render(template);

  this.$('#check-box-reason').click();
  assert.elementNotFound('.card-content-paragraph-input');
});
