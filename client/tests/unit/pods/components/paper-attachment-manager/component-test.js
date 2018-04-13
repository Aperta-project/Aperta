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
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';

moduleFor(
  'component:paper-attachment-manager',
  'Unit | Component | paper attachment manager',
  {
    // Specify the other units that are required for this test
    // needs: ['component:foo', 'helper:bar'],
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      this.registry.register(
        'pusher:main',
        Ember.Object.extend({ socketId: 'foo' })
      );
    }
  }
);

test(`creating a new paper file`, function(assert) {
  let done = assert.async();
  let cardEvent = this.container.lookup('service:card-event');
  cardEvent.on('onPaperFileUploaded', name => {
    assert.equal(
      name,
      'sourcefile',
      'it triggers the event with the attachment type'
    );
    done();
  });

  let task = make('task', { paper: make('paper') });
  let component = this.subject({ attachmentType: 'sourcefile', task });

  $.mockjax({
    url: `/api/tasks/${task.id}/upload_manuscript`,
    type: 'POST',
    status: 201,
    responseText: { sourcefileAttachment: {id: 1} }
  });
  Ember.run(() => {
    component.send('createFile', 'fakeUrl', 'file');
  });
});
