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

// Receives info on current order state
//   activeOrderBy:  null,
//   activeOrderDir: null,
//
// Calls a closure action when clicked, saying what the new
// order state should be:
//   it's configured sort field (orderBy)
//   the appropriate new sort direction
//
// Intended to be used to call out an action that will trigger a model
// collection reload, which will trigger re reload of the template.
// This means that state binding, is not only unnecessary, it is not desired,
// since we want the response from server to set the state
export default Ember.Component.extend({
  tagName: 'a',
  classNames: ['sort-link'],
  classNameBindings: [
    'active:active',
  ],
  attributeBindings: ['title'],


  // attrs
  text:           null,
  orderBy:        null,
  activeOrderBy:  null,
  activeOrderDir: null,

  // action
  sortAction:     null,

  isAsc: Ember.computed('activeOrderDir', function(){
    return Ember.isEqual(this.get('activeOrderDir'), 'asc');
  }),

  title: Ember.computed('activeOrderDir', function(){
    return "sort by " + this.get('text')
  }),

  caretDir: Ember.computed('activeOrderDir', function(){
    return this.get('isAsc') ? 'up' : 'down';
  }),

  orderDir: Ember.computed('activeOrderDir', function(){
    if (this.get('active')) {
      return this.get('isAsc') ? 'desc' : 'asc';
    } else {
      return 'asc';
    }
  }),

  active: Ember.computed('orderBy', 'activeOrderBy', function() {
    return Ember.isEqual(this.get('orderBy'), this.get('activeOrderBy'));
  }),

  click() {
    this.get('sortAction')(this.get('orderBy'), this.get('orderDir'));
  }
});
