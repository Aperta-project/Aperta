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

export default Ember.Component.extend({
  classNames: ['simple-pagination'],
  page: null,       // pass in
  totalCount: null, // pass in
  perPage: null,    // pass in
  setPage() {},     // pass in as closure action

  init() {
    this._super(...arguments);
    this.set('page', parseInt(this.get('page'))); // params come in as str
  },

  pages: Ember.computed(function(){
    return Math.ceil(this.get('totalCount') / this.get('perPage'))
  }),

  pagesUI: Ember.computed(function(){
    if (this.get('totalCount') == 0) { return '1'; }
    if (!this.get('totalCount')) { return '?'; }
    return this.get('pages');
  }),

  hasPrev: Ember.computed(function(){
    return this.get('page') > 1
  }),

  hasNext: Ember.computed(function(){
    return this.get('page') < this.get('pages')
  }),

  actions: {
    prev() {
      this.setPage(this.get('page') - 1);
    },

    next() {
      this.setPage(this.get('page') + 1);
    }
  }
});
