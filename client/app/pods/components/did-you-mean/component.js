import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service('restless'),
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
  debounce: 300,

  // props:
  highlightedItem: null,
  resultText: null,
  searchAllowed: true,
  searchResults: null,
  previousSearch: null,
  selectedItem: null,
  recognized: false,
  searching: 0,
  focused: false,

  errorPresent: Ember.computed('errors', function() {
    return !Ember.isEmpty(this.get('errors'));
  }),

  selectItem(item) {
    this.set('selectedItem', item);
    this.sendAction('itemSelected', item);
    let textForInput = this.itemNameFunction(item);

    this.set('resultText', textForInput);
    this.set('searchResults', null);
    this.set('recognized',  true);
  },

  findPerfectMatch() {
    let lookingFor = this.get('resultText').toLowerCase();
    let lookingIn = this.get('searchResults');
    let found = _.find(lookingIn, (item) => {
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

  actions: {
    selectItem(item) {
      this.selectItem(item);
    },

    search() {
      this.set('focused', false);
      let search = this.get('resultText');
      if (!search || search === this.previousSearch) { return; }

      this.incrementProperty('searching');
      this.previousSearch = search;
      this.set('searchResults', null);

      let url = this.get('endpoint');
      let data = {};
      data[this.get('queryParameter')] = search;

      this.get('restless').get(url, data).then((response) => {
        this.decrementProperty('searching');
        let results = this.get('parseResponseFunction')(response);
        if (results.length === 0) {
          this.selectUnknown();
        } else {
          this.set('searchResults',  results);
        }

        this.findPerfectMatch();
      });
    },

    tryAgain() {
      if (this.get('disabled')) { return; }
      this.set('selectedItem', null);
      this.previousSearch = null;
    },

    selectUnknownItem() {
      this.selectUnknown();
    },

    focus() {
      this.set('focused', true);
    }
  }
});
