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
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';

moduleForComponent(
  'card-content/check-box',
  'Integration | Component | card content | check box',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('actionStub', function() {});
      this.set('content', Ember.Object.create({ ident: 'test' }));
      this.set('answer', Ember.Object.create({ value: null }));
      this.set('repetition', null);
      this.set('owner', Ember.Object.create());

      this.labelAndText = Ember.Object.create({ text: '<b class="foo">Foo</b>', label: 'some label' });
      this.labelOnly = Ember.Object.create({ label: 'some label' });
      this.textOnly = Ember.Object.create({ text: '<b class="foo">Foo</b>' });
    }
  }
);

let template = hbs`{{card-content/check-box
answer=answer
content=content
disabled=disabled
repetition=repetition
owner=owner
valueChanged=(action actionStub)
}}`;

test(`it disables the input if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('input[disabled]');
});

test(`it is checked if the answer is truthy`, function(assert) {
  this.set('answer', Ember.Object.create({ value: true }));
  this.render(template);
  assert.elementFound('.card-content-check-box input:checked');
});

test(`it sends 'valueChanged' on change`, function(assert) {
  assert.expect(1);
  this.set('actionStub', function(newVal) {
    assert.equal(newVal, true, 'it calls the action with the new value');
  });
  this.render(template);
  this.$('input').click();
});
