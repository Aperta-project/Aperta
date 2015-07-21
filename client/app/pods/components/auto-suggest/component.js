import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  // attrs:
  endpoint: null,
  queryParameter: null,
  parseResponseFunction: null,
  itemDisplayTextFunction: null,
  placeholder: null,

  // props:
  highlightedItem: null,
  resultText: null,
  searchAllowed: true,
  searchResults: null,
  selectedItem: null,

  search() {
    let url = this.get('endpoint');
    let data = {};
    data[this.get('queryParameter')] = this.get('resultText');

    RESTless.get(url, data).then((response) => {
      let results = this.get('parseResponseFunction')(response);
      this.set('searchResults',  results);
    });
  },

  _resultTextChanged: Ember.observer('resultText', function() {
    if(this.get('searchAllowed')) {
      Ember.run.debounce(this, this.search, 150);
    }

    this.set('searchAllowed', true);
  }),

  _setupKeybindings: Ember.on('didInsertElement', function() {
    $(document).on('keyup.autosuggest', (event)=> {
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
