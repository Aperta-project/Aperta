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
  namedComputedProperty,
  diffableTextForQuestion
} from 'tahi/lib/snapshots/snapshot-named-computed-property';

const { computed } = Ember;

const DiffableAuthor = Ember.Object.extend({
  author: null, // this gets passed in
  position: namedComputedProperty('author', 'position'),
  name: namedComputedProperty('author', 'name'),
  contactFirstName: namedComputedProperty('author', 'contact_first_name'),
  contactMiddleName: namedComputedProperty('author', 'contact_middle_name'),
  contactLastName: namedComputedProperty('author', 'contact_last_name'),

  email: namedComputedProperty('author', 'contact_email'),
  initials: namedComputedProperty('author', 'initial'),

  government: diffableTextForQuestion(
    'author',
    'group-author--government-employee'),

  contributions: computed('author.children.[]', function() {
    var contributions = _.findWhere(
      this.get('author').children,
      {name: 'group-author--contributions'}
    ) || [];

    var selectedNames = _.compact(_.map(
      contributions.children,
      function(contribution) {
        if (!contribution.value.answer) { return null; }
        return contribution.value.title;
      }
    ));

    return selectedNames.join(', ');
  })
});

export default Ember.Component.extend({
  viewingAuthor: null, //Snapshots are passed in
  comparingAuthor: null,

  viewing: computed('viewingAuthor', function() {
    return DiffableAuthor.create(
      { author: this.get('viewingAuthor') } );
  }),

  comparing: computed('comparingAuthor', function() {
    if (!this.get('comparingAuthor')) { return {}; }
    return DiffableAuthor.create(
      { author: this.get('comparingAuthor') } );
  })
});
