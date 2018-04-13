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

import {moduleFor,  test} from 'ember-qunit';
import {make, manualSetup } from 'ember-data-factory-guy';

moduleFor('component:card-content', 'Unit: Card Content Component', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
  }
});

test('it lazily saves new answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: false, defaultAnswerValue: null });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false, repetition: null});

  assert.notOk(component.shouldEagerlySave(answer));
});

test('it eagerly saves new required answers', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: true });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = cardContent.answerForOwner(task);
  let component = this.subject({content: cardContent, owner: task, preview: false, repetition: null});

  assert.ok(component.shouldEagerlySave(answer));
});

test('it eagerly saves new answers with default values', function(assert) {
  let cardContent = make('card-content', 'shortInput', { defaultAnswerValue: 'hippopotamus' });
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);

  let answer = cardContent.answerForOwner(task);
  assert.equal(answer.get('value'), 'hippopotamus');

  let component = this.subject({content: cardContent, owner: task, preview: false, repetition: null});
  assert.ok(component.shouldEagerlySave(answer));
});
