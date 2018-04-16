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

import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', {
    async: true
  }),
  source: DS.belongsTo('snapshottable', {
    async: true,
    inverse: 'snapshots',
    polymorphic:  true
  }),
  // We have sourceId here to allow comparing sources without
  // *fetching* sources. *sigh* ember data.
  sourceId: DS.attr('string'),
  majorVersion: DS.attr('number'),
  minorVersion: DS.attr('number'),
  contents: DS.attr(),
  sanitizedContents: DS.attr(),
  createdAt: DS.attr('date'),
  fullVersion: Ember.computed('majorVersion', 'minorVersion', function() {
    return `${this.get('majorVersion')}.${this.get('minorVersion')}`;
  }),
  fileType: DS.attr('string'),

  createdAtOrNow: Ember.computed(
    'createdAt',
    function() {
      return (this.get('createdAt') || new Date());
    }),

  versionString: Ember.computed(
    'majorVersion', 'minorVersion',
    function() {
      if (Ember.isEmpty(this.get('majorVersion'))) {
        return '(draft)';
      } else {
        return `R${this.get('majorVersion')}.${this.get('minorVersion')}`;
      }
    }),

  hasDiff(otherSnapshot) {
    if (!otherSnapshot) {
      return true;
    }

    let string1 = JSON.stringify(this.get('sanitizedContents'));
    if(otherSnapshot){
      let string2 = JSON.stringify(otherSnapshot.get('sanitizedContents'));
      return string1 !== string2;
    } else {
      return false;
    }
  }
});
