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

var FigureSnapshot = Ember.Object.extend({
  snapshot: null,
  file: namedComputedProperty('snapshot', 'file'),
  title: namedComputedProperty('snapshot', 'title'),
  fileHash: namedComputedProperty('snapshot', 'file_hash'),
  url: namedComputedProperty('snapshot', 'url')
});

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['figure-snapshot'],
  tagName: 'tr',

  figure1: Ember.computed('snapshot1.children.[]', function() {
    return FigureSnapshot.create({snapshot: this.get('snapshot1')});
  }),

  figure2: Ember.computed('snapshot2.children.[]', function() {
    return FigureSnapshot.create({snapshot: this.get('snapshot2')});
  }),

  fileHashChanged: Ember.computed(
    'figure1.fileHash',
    'figure2.fileHash',
    function() {
      var hash1 = this.get('figure1.fileHash');
      var hash2 = this.get('figure2.fileHash');
      if (!hash1 || !hash2) {
        return false;
      } else {
        return hash1 !== hash2;
      }
    }
  )
});
