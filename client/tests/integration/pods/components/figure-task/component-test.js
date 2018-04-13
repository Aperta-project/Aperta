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
import { manualSetup, make } from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import customAssertions from 'tahi/tests/helpers/custom-assertions';

let createTaskWithFigures = function(figures) {
  return make('figure-task', {
    paper: {
      figures: figures
    },
    nestedQuestions: [
      {id: 1, ident: "figures--complies"}
    ]
  });
}

moduleForComponent('figure-task', 'Integration | Components | Tasks | Figure', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    customAssertions();
    Factory.createPermission('figureTask', 1, ['edit', 'view']);
  }
});

let template = hbs`{{figure-task task=testTask}}`;
let errorSelector = '.figure-thumbnail .error-message:not(.error-message--hidden)'
test('it renders the paper\'s figures', function(assert) {
  let testTask = createTaskWithFigures([{rank: 1, title: 'Fig. 1', id: 1}]);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound('.figure-thumbnail', 1);

});

test('it shows an error message for figures with the same rank', function(assert) {
  let testTask = createTaskWithFigures([{rank: 1, title: 'Some Title', id: 1},
                                        {rank: 1, title: 'Another Title', id: 2}]);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound(errorSelector, 2);
});

test('it shows an error message for a non-numeric label', function(assert) {
  let testTask = createTaskWithFigures([{rank: 0, title: 'Some Title', id: 1}]);
  this.set('testTask', testTask);
  this.render(template);
  assert.elementsFound(errorSelector, 1);
});

test('it orders the figures based on rank', function(assert) {
  let testTask = createTaskWithFigures([{rank: 2, title: 'Title Two', id: 2},
                                        {rank: 0, title: 'Unlabeled', id: 3},
                                        {rank: 1, title: 'Title One', id: 1}]);
  this.set('testTask', testTask);
  this.render(template);
  let ids = this.$('.figure-thumbnail').map((_i, el) => $(el).data('figure-id')).get();
  assert.deepEqual(ids, [1, 2, 3], 'Figures are sorted with rank 0 coming last');
});
