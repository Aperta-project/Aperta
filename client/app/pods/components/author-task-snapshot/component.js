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
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id';

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,

  questionsViewing: Ember.computed('snapshot1', function() {
    if (this.get('snapshot1')) {
      return this.get('snapshot1.children').filterBy('type', 'question');
    }
  }),

  questionsComparing: Ember.computed('snapshot2', function() {
    if (this.get('snapshot2')) {
      return this.get('snapshot2.children').filterBy('type', 'question');
    }
  }),

  questions: Ember.computed('questionsViewing', 'questionsComparing',
                            function() {
    return _.zip(this.get('questionsViewing'),
                 this.get('questionsComparing') || []);
  }),

  authors: Ember.computed('snapshot1', 'snapshot2', function() {
    var authorSnapshots = new SnapshotsById('author');
    var groupSnapshots = new SnapshotsById('group-author');

    authorSnapshots.addSnapshots(this.get('snapshot1.children'));
    groupSnapshots.addSnapshots(this.get('snapshot1.children'));

    if (this.get('snapshot2.children')) {
      authorSnapshots.addSnapshots(this.get('snapshot2.children'));
      groupSnapshots.addSnapshots(this.get('snapshot2.children'));
    }

    var authors = authorSnapshots.toArray();
    var groupAuthors = groupSnapshots.toArray();

    var allAuthors = authors.concat(groupAuthors);
    return _.sortBy(allAuthors, function(author) {
      if (author[0]) {
        return _.find(author[0].children, function(item) {
          return item.name === 'position';
        }).value;
      }
      return Number.MAX_SAFE_INTEGER; // Sort removed authors to the bottom
    });
  })
});
