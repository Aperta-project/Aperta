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
import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'paper-attachment-manager',
  'Integration | Component | paper attachment manager',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);

      this.registry.register(
        'service:pusher',
        Ember.Object.extend({ socketId: 'foo' })
      );
    },
    afterEach() {
      $.mockjax.clear();
    }
  }
);

test(`deleting an errored file posts to destroy the file`, function(assert) {
  this.set(
    'task',
    make('upload-manuscript-task', {
      paper: {
        file: { status: 'error' }
      }
    })
  );

  this.set('attachmentType', 'manuscript');
  this.render(
    hbs`{{paper-attachment-manager attachmentType=attachmentType task=task disabled=false}}`
  );

  let mockUrl = `/api/tasks/${this.get('task.id')}/delete_manuscript`;
  let mockInfo = { url: mockUrl, type: 'DELETE', status: 204 };
  $.mockjax(mockInfo);

  assert.textPresent('.error-message', 'There was an error');
  assert.elementFound('.upload-cancel-button');
  this.$('.upload-cancel-button').click();
  return wait().then(() => {
    assert.mockjaxRequestMade(mockUrl, 'DELETE');
  });
});

test(`deleting a sourcefile uses a different endpoint`, function(assert) {
  this.set(
    'task',
    make('upload-manuscript-task', {
      paper: {
        sourcefile: { status: 'error' }
      }
    })
  );

  this.set('attachmentType', 'sourcefile');
  this.render(
    hbs`{{paper-attachment-manager attachmentType=attachmentType task=task disabled=false}}`
  );

  let mockUrl = `/api/tasks/${this.get('task.id')}/delete_sourcefile`;
  let mockInfo = { url: mockUrl, type: 'DELETE', status: 204 };
  $.mockjax(mockInfo);

  assert.textPresent('.error-message', 'There was an error');
  assert.elementFound('.upload-cancel-button');
  this.$('.upload-cancel-button').click();
  return wait().then(() => {
    assert.mockjaxRequestMade(mockUrl, 'DELETE');
  });
});
