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

import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('overlay-task-header', 'Integration | Component | overlay task header', {
  integration: true,
  beforeEach() {
    this.set('animation', () => {});

    this.set('displayTask', Ember.Object.create({
      id: 'id-1',
      title: 'Adhoc Task',
      type: 'AdHocTask',
      paper: Ember.Object.create({
        id: 'id-2',
        index: 'papers',
        manuscript_id: 'test.10001',
        paperType: 'Research',
        publishingState: 'submitted',
        displayTitle: 'Chemistry is Amazing',
        creator: Ember.Object.create({
          name: 'Anna Author'
        })
      })
    }));

    this.render(hbs`
      {{overlay-task-header task=displayTask animateOut=animation}}
    `);
  }
});

test('basic paper information is included in overlay header', function(assert) {
  assert.textPresent('li.paper-creator', 'Anna Author', 'displays author name');
  assert.textPresent('li.paper-manuscript-id', 'test.10001', 'displays manuscript id');
  assert.textPresent('li.paper-type', 'Research', 'displays article type');
  assert.textPresent('li.paper-publishing-state', 'Submitted', 'displays manuscript status');
  assert.textPresent('.task-overlay-paper-title', 'Chemistry is Amazing', 'displays paper title');
});
