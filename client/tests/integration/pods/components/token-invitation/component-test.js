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

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('token-invitation', 'Integration | Component | token invitation', {
  integration: true,
  beforeEach() {
    this.set('declineDone', false);
    this.set('model', Ember.Object.create({
      token: 'abc',
      save: function() { return Ember.RSVP.resolve(); },
      setDeclined: function() {}
    }));
  }
});

let template = hbs `{{token-invitation model=model declineDone=declineDone}}`;

test('displays inactive message if already declined', function(assert){
  this.render(template);

  assert.elementFound('.message.inactive', 'Displays inactive message');
  assert.elementNotFound('.message.thankyou', 'Does not display thank you message');
});

test('displays inactive message if already declined', function(assert){
  this.set('declineDone', true);
  this.render(template);

  assert.elementFound('.message.thankyou', 'Displays thank you message');
});

test('displays invitations-x component when invited', function(assert){
  this.set('model.pendingFeedback', true);
  this.render(template);
  assert.elementFound('.dashboard-open-invitations', 'Displays invitation');
});

test('Buttons trigger saves, resulting in thank you message', function(assert) {
  assert.expect(3);
  this.set('model.pendingFeedback', false);
  this.set('model.invited', true);
  this.set('model.save', function() {
    assert.ok(true, 'Model is saved on decline and submit feedback button click');
    return Ember.RSVP.resolve();
  });
  this.render(template);
  this.$('.invitation-decline').click(); // acquire feedback
  this.$('.send-feedback').click();
  assert.elementFound('.message.thankyou', 'Displays thank you message');
});
