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

export default Ember.Controller.extend({
  queryParams: ['page', 'query', 'orderBy', 'orderDir'],

  // are set in route when in url
  // are reset on user page events
  page:     null,
  query:    null,
  orderBy:  null,
  orderDir: null,

  // are set in route w server meta data
  perPage:    null,
  totalCount: null,

  //on-page props
  queryInput: null,

  // true when naming a new saved query
  newQueryState: false,
  newQueryTitle: '',

  actions: {
    setPage(page) {
      this.set('page', page);
    },

    sort(orderBy, orderDir) {
      this.set('orderBy',  orderBy);
      this.set('orderDir', orderDir);
      this.set('page',     1);
    },

    search() {
      this.set('orderBy',  null);
      this.set('orderDir', null);
      this.set('page',     null);
      this.set('query', this.get('queryInput'));
    },

    clearSearch() {
      this.set('orderBy',  null);
      this.set('orderDir', null);
      this.set('page',     null);
      this.set('query',    null);
    },

    saveQuery() {
      this.store.createRecord('paper-tracker-query', {
        title: this.get('newQueryTitle'),
        query: this.get('queryInput'),
        orderDir: this.get('orderDir'),
        orderBy: this.get('orderBy')
      }).save();
      this.set('newQueryState', false);
      this.set('newQueryTitle', '');
    },

    startNewSavedQuery() {
      this.set('newQueryState', true);
      Ember.run.later(() => {
        $('#new-query-title').focus();
      });
    }
  }
});
