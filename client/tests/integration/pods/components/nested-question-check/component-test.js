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

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('nested-question-check', 'Integration | Component | nested question check', {
  integration: true
});

test('it renders', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create(); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

  this.render(hbs`
    {{nested-question-check ident="foo" owner=task}}
  `);

  assert.equal(this.$('label:contains("Test Question")').length, 1);
});

test('when providing a block it renders additional data when initializing with a value as already checked', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create({value: true}); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

  this.render(hbs`
    {{#nested-question-check ident="foo" owner=task as |selection|}}
      {{#if selection.yieldingForAdditionalData }}
        {{#if selection.checked}}
          <div class="successfully-initialized-as-checked" />
        {{/if}}
      {{/if}}
    {{/nested-question-check}}
  `);

  assert.equal(this.$('.successfully-initialized-as-checked').length, 1);
});

test('when providing a block it renders the text provided when it yieldsForText and displayQuestionText=false', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create({value: true}); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

  this.render(hbs`
    {{#nested-question-check ident="foo" owner=task displayQuestionText=false as |selection|}}
      {{#if selection.yieldingForText }}
        <label class="custom-question">Custom question</label>
      {{/if}}
    {{/nested-question-check}}
  `);
  assert.equal(this.$('label.custom-question:contains("Custom question")').length, 1);
});
