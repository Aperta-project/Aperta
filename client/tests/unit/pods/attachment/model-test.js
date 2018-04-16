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

import { module, test } from 'ember-qunit';
import SnapshotAttachment from 'tahi/pods/snapshot/attachment/model';

module('Unit | snapshot/attachment', {
  needs: []
});

test('has properties extracted', function(assert) {
  const attachment = SnapshotAttachment.create({
    attachment: {
      name: 'some-kind-of-attachment',
      type: 'properties',
      children: [
        { name: 'id', type: 'integer', value: 32 },
        { name: 'caption', type: 'text', value: 'a caption' },
        { name: 'category', type: 'text', value: 'a category' },
        { name: 'file', type: 'text', value: 'zach-overflow.png' },
        { name: 'file_hash', type: 'text', value: 'abc123' },
        { name: 'label', type: 'text', value: 'a label' },
        { name: 'publishable', type: 'boolean', value: true },
        { name: 'status', type: 'text', value: 'done' },
        { name: 'title', type: 'text', value: 'proton.jpg' },
        { name: 'url', type: 'url', value: '/resource_proxy/4pj5bv7E5A9RbJfP7hGi5sds' }
      ]
    }
  });

  assert.equal(attachment.get('id'), 32, 'id was read');
  assert.equal(attachment.get('caption'), 'a caption', 'caption was read');
  assert.equal(attachment.get('category'), 'a category', 'category was read');
  assert.equal(attachment.get('file'), 'zach-overflow.png', 'file was read');
  assert.equal(attachment.get('fileHash'), 'abc123', 'fileHash was read');
  assert.equal(attachment.get('label'), 'a label', 'label was read');
  assert.equal(attachment.get('publishable'), true, 'publishable was read');
  assert.equal(attachment.get('status'), 'done', 'status was read');
  assert.equal(attachment.get('title'), 'proton.jpg', 'title was read');
  assert.equal(attachment.get('url'), '/resource_proxy/4pj5bv7E5A9RbJfP7hGi5sds', 'url was read');
});
