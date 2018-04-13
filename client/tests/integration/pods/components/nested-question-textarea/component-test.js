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
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createQuestion } from 'tahi/tests/factories/nested-question';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
import {setRichText} from 'tahi/tests/helpers/rich-text-editor-helpers';

moduleForComponent('nested-question-textarea', 'Integration | Component | nested question textarea', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
    this.registry.register('service:can', FakeCanService);

    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('nested-question-answer');
    };
  },

  afterEach() {
    $.mockjax.clear();
  }
});

test('saves on change events', function(assert) {
  let task =  make('ad-hoc-task');
  let fake = this.container.lookup('service:can');
  let url = '/api/nested_questions/1/answers';

  fake.allowPermission('edit', task);
  createQuestion(task, 'foo');
  this.set('task', task);

  this.render(hbs`{{nested-question-textarea ident="foo" owner=task}}`);
  $.mockjax({url: url, type: 'POST', status: 201, responseText: {nested_question_answer: {id: '1'}}});
  setRichText('foo', 'new comment');

  return wait().then(() => {
    assert.mockjaxRequestMade(url, 'POST', 'it saves the new answer on change');
  });
});

test('shows help text in disabled state', function(assert) {
  let task =  make('ad-hoc-task');
  createQuestion(task, 'foo');
  this.set('task', task);

  this.render(hbs`{{nested-question-textarea ident="foo" owner=task helpText="Something helpful" disabled=true}}`);

  assert.textPresent('.question-help', 'Something helpful');
});
