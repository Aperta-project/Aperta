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

moduleForComponent('admin-page/workflow-thumbnail',
  'Integration | Component | admin page | workflow thumbnail', {
    integration: true
  }
);

const workflow = {
  paperType: 'Research',
  updatedAt: '2017-02-07T13:54:58.028Z',
  activePaperCount: 1
};


test('it shows the paper type', function(assert) {
  this.set('workflow', workflow);
  this.render(hbs`{{admin-page/workflow-thumbnail workflow=workflow}}`);

  assert.textPresent('.admin-workflow-thumbnail-name', 'Research');
});


test('it shows when the workflow was last updated', function(assert) {
  this.set('workflow', workflow);
  this.render(hbs`{{admin-page/workflow-thumbnail workflow=workflow}}`);

  assert.textPresent('.admin-workflow-thumbnail-updated', 'Feb 7, 2017');
});


test('it shows the number of active manuscripts', function(assert) {
  this.set('workflow', workflow);
  this.render(hbs`{{admin-page/workflow-thumbnail workflow=workflow}}`);

  assert.textPresent(
    '.admin-workflow-thumbnail-active-manuscripts',
    '1 Active Manuscript'
  );
});
