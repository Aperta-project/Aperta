import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  classNames: ['form-control', 'auto-suggest-border'],

  // attrs:
  endpoint: null,
  queryParameter: null,
  parseResponseFunction: null,
  itemDisplayTextFunction: null,
  placeholder: null,
  debounce: 300,

  // props:
  highlightedItem: null,
  resultText: null,
  searchAllowed: true,
  searchResults: null,
  selectedItem: null,
  searching: 0,

  search() {
    if (!this.get('resultText')) return;

    this.incrementProperty('searching');
    let url = this.get('endpoint');
    let data = {};
    data[this.get('queryParameter')] = this.get('resultText');

    RESTless.get(url, data).then((response) => {
      let results = this.get('parseResponseFunction')(response);
      this.set('searchResults',  results);
      this.decrementProperty('searching');
    },
    (response) => {
      this.decrementProperty('searching');
    });
  },

  _resultTextChanged: Ember.observer('resultText', function() {
    if(this.get('searchAllowed')) {
      Ember.run.debounce(this, this.search, this.get('debounce'));
    }

    this.set('searchAllowed', true);
  }),

  _setupKeybindings: Ember.on('didInsertElement', function() {
    $(document).on('keyup.autosuggest', (event) => {
      if (event.which === 27) {
        this.set('highlightedItem', null);
      }

      if(event.which === 13 || event.which === 27) {
        let highlightedItem = this.get('highlightedItem');

        if(highlightedItem) {
          this.selectItem(highlightedItem);
        } else {
          this.sendAction('unknownItemSelected', this.get('resultText'));
        }
        this.set('highlightedItem', null);
        this.set('searchResults', null);
      }
    });
  }),

  selectItem(item) {
    this.set('searchAllowed', false);
    this.set('selectedItem', item);
    this.sendAction('itemSelected', item);
    let textForInput = this.itemDisplayTextFunction(item);

    this.set('resultText', textForInput);
    this.set('searchResults', null);
  },

  actions: {
    selectItem(item) {
      this.selectItem(item);
    }
  }
});
