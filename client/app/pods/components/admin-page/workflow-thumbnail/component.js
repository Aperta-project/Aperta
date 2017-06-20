import Ember from 'ember';

export default Ember.Component.extend({
  workflow: {},

  classNames: [],
  confirmDestroy: false,

  actions: {
    toggleConfirmDestroy() {
      this.toggleProperty('confirmDestroy');
    },

    destroyTemplate() {
      // this.attrs.destroyTemplate(this.get('model'));
    }
  }
});
