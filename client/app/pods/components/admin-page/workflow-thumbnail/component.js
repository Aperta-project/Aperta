import Ember from 'ember';

export default Ember.Component.extend({
  workflow: {},
  classNames: [],
  confirmDestroy: false,

  actions: {
    toggleConfirmDestroy() {
      this.toggleProperty('confirmDestroy');
    },
    hideConfirmDestroy() {
      this.set('confirmDestroy', false);
    },
    destroyTemplate() {
      this.attrs.destroyTemplate(this.get('workflow'));
    }
  }
});
