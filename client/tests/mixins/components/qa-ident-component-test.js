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

import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';
import QAIdent from 'tahi/mixins/components/qa-ident';

let content = Ember.Object.create({ 'ident' : 'my-ident' });

moduleFor('mixin:qa-ident', 'Unit | Mixin | qa-ident', {
  integration: true,

  subject() {
    const component = Ember.Object.extend(QAIdent, {}).create();
    component.set('content', content);
    return component;
  }
});

test('classNameBindings includes QAIdent', function(assert) {
  assert.deepEqual(this.subject().get('classNameBindings'), ['QAIdent']);
});

test('QAIdent returns the right value', function(assert) {
  assert.equal(this.subject().get('QAIdent'), 'qa-ident-my-ident');
});


test('QAIdent squashes disallowed characters', function(assert) {
  content = Ember.Object.create({ 'ident' : 'my ident 1234!@#$%^&' });
  assert.equal(this.subject().get('QAIdent'), 'qa-ident-my_ident____________');
});
