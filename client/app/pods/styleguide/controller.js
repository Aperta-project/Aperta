import Ember from 'ember';

export default Ember.Controller.extend({
  selectBoxSelection: null,
  showAutoSuggest: false,
  formatInputValue: null,

  actions: {
    clearSelectBoxSelection() {
     this.set('selectBoxSelection', null);
    },

    selectSelectBoxSelection(selection) {
      this.set('selectBoxSelection', selection);
    }
  }
});
