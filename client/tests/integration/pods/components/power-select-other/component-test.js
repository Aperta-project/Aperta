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

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import {
  mousedown as powerSelectFocus, mouseup as powerSelectChoose
} from 'tahi/lib/power-select-event-trigger';

import Ember from 'ember';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('power-select-other', 'Integration | Component | power select other', {
  integration: true,

  beforeEach() {
    this.setProperties({
      nameValue: null,
      names: ['Felix', 'Sara', 'John']
    });
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(this.$('.ember-power-select-trigger').length, 1, 'select renders');
});

test('initial value is selected', function(assert) {
  assert.expect(1);
  this.set('nameValue', 'Sara');

  this.render(hbs`
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(
    this.$('.ember-power-select-trigger').text().trim(),
    'Sara',
    'initial value is selected'
  );
});

test('input displayed when other option is selected', function(assert) {
  assert.expect(2);
  this.set('nameValue', 'Gena');

  this.render(hbs`
    <span id="selected-name">{{nameValue}}</span>
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(
    this.$('input').length,
    1,
    'input is visible'
  );


  Ember.run(() => {
    powerSelectFocus(this.$('.ember-power-select-trigger'));
  });

  Ember.run(() => {
    powerSelectChoose($('.ember-power-select-option:contains("John")'));
  });

  Ember.run(() => {
    assert.equal(
      this.$('#selected-name').text().trim(),
      'John',
      'value property is changed'
    );
  });
});
