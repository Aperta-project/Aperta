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
import {
  namedComputedProperty
} from 'tahi/lib/snapshots/snapshot-named-computed-property';

export default Ember.Object.extend({
  attachment: null,

  id: namedComputedProperty('attachment', 'id'),
  caption: namedComputedProperty('attachment', 'caption'),
  category: namedComputedProperty('attachment', 'category'),
  file: namedComputedProperty('attachment', 'file'),
  fileHash: namedComputedProperty('attachment', 'file_hash'),
  label: namedComputedProperty('attachment', 'label'),
  publishable: namedComputedProperty('attachment', 'publishable'),
  status: namedComputedProperty('attachment', 'status'),
  title: namedComputedProperty('attachment', 'title'),
  url: namedComputedProperty('attachment', 'url'),
  ownerType: namedComputedProperty('attachment', 'owner_type'),
  ownerId: namedComputedProperty('attachment', 'owner_id'),
  isImage: Ember.computed('file', function() {
    return (/\.(gif|jpg|jpeg|tiff|png)$/i).test(this.get('file'));
  }),
  previewUrl: Ember.computed('url', function() {
    return this.get('url') + '/preview';
  })
});
