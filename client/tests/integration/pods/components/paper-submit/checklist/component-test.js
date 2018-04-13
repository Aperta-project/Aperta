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

import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';

moduleForComponent(
  'component:paper/paper-submit',
  'Integration | Component | paper submit checklist',
  { integration: true,
    beforeEach() {

      initTruthHelpers();
    }
  }
);

let template = hbs`{{paper-submit/checklist completedStage=completedStage}}`

test('it renders stage numbers from completedStage', function(assert) {
  this.set('completedStage', 2);
  this.render(template);
  assert.elementsFound(
    '.fa-check',
    2,
    'renders a check for each complete stage'
  );
  assert.textPresent(
    '.ball.img-circle',
    '3',
    'shows a number for the uncompleted stage'
  );
  this.set('completedStage', 0);
  assert.elementsFound('.fa-check', 0, 'no checks found');
  assert.textPresent('.ball.img-circle', '123', 'all numbers rendered');

});

test('it adds the bright class from completedStage', function(assert) {
  this.set('completedStage', 2);
  this.render(template);
  assert.elementsFound('.bright', 2)
});
