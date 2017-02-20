import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['left-drawer', 'left-drawer-width'],

  actions: {
    onToggle() {
      this.get('onToggle')();
    }
  }
});
