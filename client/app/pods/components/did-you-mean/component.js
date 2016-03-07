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
    'errorPresent:error'
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
    this.set('searchResults', null);
    this.set('recognized',  true);
  },

  findPerfectMatch() {
    const lookingFor = this.get('resultText').toLowerCase();
    const lookingIn  = this.get('searchResults');
    const found = _.find(lookingIn, (item) => {
      return lookingFor === this.get('itemNameFunction')(item).toLowerCase();
    });
    if (found) {
      this.selectItem(found);
    }
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

    if (isEmpty(results)) {
      this.selectUnknown();
    } else {
      this.set('searchResults', results);
    }

    this.findPerfectMatch();
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

    selectUnknownItem() {
      this.selectUnknown();
    },

    focus() {
      this.set('focused', true);
    }
  }
});
