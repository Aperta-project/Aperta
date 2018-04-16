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

moduleForComponent('admin-page/workflow-catalogue',
  'Integration | Component | Admin Page | Workflow Catalogue', {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
    }
  }
);

const workflow = {
  paperType: 'Research',
  updatedAt: '2017-02-07T13:54:58.028Z',
  activePaperCount: 1
};

test('it renders a catalogue item for each workflow', function(assert) {
  const workflows = [workflow, workflow, workflow];
  this.set('workflows', workflows);

  this.render(hbs`
    {{admin-page/workflow-catalogue workflows=workflows}}
  `);

  assert.nElementsFound('.admin-workflow-thumbnail', workflows.length);
});
