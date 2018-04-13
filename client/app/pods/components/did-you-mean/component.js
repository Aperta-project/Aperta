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
  task,
  timeout
} from 'ember-concurrency';

import getJSONTask from 'tahi/lib/get-json-task';

const {
  Component,
  computed,
  isEmpty
} = Ember;

export default Component.extend({
  classNameBindings: [
    ':did-you-mean',
    'errorPresent:did-you-mean--error'
  ],
  // attrs:
  endpoint: null,
  queryParameter: null,
  parseResponseFunction: null,
  unknownItemFunction: null,
  itemNameFunction: null,
  placeholder: null,
  debounce: 200,

  // props:
  highlightedItem: null,
  resultText: null,
  searchAllowed: true,
  searchResults: null,
  previousSearch: null,
  selectedItem: null,
  recognized: false,
  focused: false,

  errorPresent: computed('errors', function() {
    return !isEmpty(this.get('errors'));
  }),

  selectItem(item) {
    this.set('selectedItem', item);
    this.sendAction('itemSelected', item);
    const textForInput = this.itemNameFunction(item);

    this.set('resultText', textForInput);
    // The institution is recognized if it has an institution-id
    this.set('recognized',  !!item['institution-id']);
    this.set('searchResults', null);
  },

  keyDown() {
    // This is a hack that removes the results when the search field is empty
    this.set('searchResults', null);
  },

  search: task(function * (url, data) {
    yield timeout(this.get('debounce'));

    const response = yield this.get('getData').perform(url, data);
    const results  = this.get('parseResponseFunction')(response);
    // Add the search param to the results if it doesn't already exist
    // so its available for the user to click
    if (!results.isAny('name', data.query)) {
      results.push({ name: data.query });
    }
    this.set('searchResults', results);
  }).restartable(),

  getData: getJSONTask,

  actions: {
    selectItem(item) {
      this.selectItem(item);
    },

    search() {
      this.set('focused', false);
      let search = this.get('resultText');
      if (isEmpty(search) || search === this.get('previousSearch')) { return; }

      const data = {};
      data[this.get('queryParameter')] = search;

      this.set('previousSearch', search);
      this.get('search').perform(this.get('endpoint'), data);
    },

    tryAgain() {
      if (this.get('disabled')) { return; }
      this.set('selectedItem', null);
      this.set('previousSearch', null);
    },

    focus() {
      this.set('focused', true);
    }
  }
});
