import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['mmt-thumbnail', 'blue-box'],

  // properties:
  confirmDestroy: false,

  // attrs:
  // canDestroy

  actions: {
    toggleConfirmDestroy() {
      this.toggleProperty('confirmDestroy');
    },

    destroyTemplate() {
      this.attrs.destroyTemplate(this.get('model'));
    }
  }
});
