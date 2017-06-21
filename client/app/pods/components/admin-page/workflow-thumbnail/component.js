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
    destroyWorkflow() {
      this.attrs.destroyWorkflow(this.get('workflow'));
    }
  }
});
