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

moduleForComponent('invitation-detail-row-accept-fields', 'Integration | Component | invitation detail row accept fields', {
  integration: true,
  beforeEach(){
    this.set('invitation', Ember.Object.create({email: 'foo@bar.com'}));
    this.set('displayAcceptFields', true);
    this.set('cancelAccept', function(){});
    this.set('loading', false);
    this.set('acceptInvitation', function(){});
  }
});

let template = hbs`{{invitation-detail-row-accept-fields
                      invitation=invitation
                      displayAcceptFields=displayAcceptFields
                      cancelAccept=cancelAccept
                      loading=loading
                      acceptInvitation=acceptInvitation}}`;

test('it is disabled by default', function(assert) {
  this.set('displayAcceptFields', false);
  this.render(template);
  assert.elementNotFound('.instructions', 'Does not display anything if displayAcceptFields is false');
});

test('displays instructins for invitation email', function(assert) {
  this.render(template);
  assert.textPresent('.instructions', this.get('invitation.email'), 'Displays email in instruction field');
});

test('it displays validation errors and prevents save', function(assert) {
  assert.expect(1);
  var callback = () => {
    assert.ok(true, 'This should not be called');
  };
  this.set('acceptInvitation', callback);
  this.render(template);
  this.$('.accept').click();
  assert.textPresent('.error', 'This field is required');
});

test('it binds in the stub invitee fields, and the object is passed into the callback', function(assert) {
  assert.expect(2);
  var firstName = 'wat';
  var lastName = 'who';
  var callback = (obj) => {
    assert.equal(obj.get('firstName'), firstName);
    assert.equal(obj.get('lastName'), lastName);
  };
  this.set('acceptInvitation', callback);
  this.set('cancelAccept', function() { return; });
  this.render(template);
  this.$('.cancel').click(); // cancel button shouldn't affect outcome of the test
  this.$("input[id*='fname']").val(firstName).change();
  this.$("input[id*='lname']").val(lastName).change();
  this.$('.accept').click();
});

test('cancel button should clear validation errors, reset fields and invoke callback', function(assert) {
  assert.expect(3);
  var callback = () => { assert.ok(true, 'Callback is called'); };
  var firstName = 'wat';
  this.set('cancelAccept', callback);
  this.render(template);
  this.$("input[id*='fname']").val(firstName).change();
  this.$('.accept').click();
  this.$('.cancel').click();
  assert.ok(!this.$("input[id*='fname']").val()), 'Input field is blank';
  assert.elementNotFound('.error', 'Error fields cleared');
});
