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

  selectUnknown() {
    this.selectItem(
      this.get('unknownItemFunction')(
        this.get('resultText')));
    this.set('recognized', false);
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
