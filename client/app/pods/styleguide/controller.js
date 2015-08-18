import Ember from 'ember';

export default Ember.Controller.extend({
  selectBoxSelection: null,
  actions: {
    clearSelectBoxSelection() {
     this.set('selectBoxSelection', null);
    },
    selectSelectBoxSelection(selection) {
      this.set('selectBoxSelection', selection);
    }
  }
});
