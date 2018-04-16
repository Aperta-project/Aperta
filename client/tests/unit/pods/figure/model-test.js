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

import { moduleForModel, test } from 'ember-qunit';
import Ember from 'ember';

moduleForModel('figure', 'Unit | Model | figure', {
  integration: true
});

test('makes its paper reload when it is deleted', function(assert) {
  assert.expect(1);
  const start = assert.async();
  let mockPaper = {
    reload() { assert.ok(true, 'reload called'); start();}
  };
  const model = this.subject();
  model.paper = mockPaper;
  Ember.run(() => {
    model.destroyRecord();
  });
});

test('makes its paper reload when it is saved', function(assert) {
  assert.expect(1);
  const start = assert.async();
  let mockPaper = {
    reload() { assert.ok(true, 'reload called'); start();}
  };
  const model = this.subject();
  model.paper = mockPaper;

  $.mockjax({url: /figures/, type: 'POST', status: 201, responseText: {figure: {id: '1'}}});

  Ember.run(() => {
    model.save();
  });
});
