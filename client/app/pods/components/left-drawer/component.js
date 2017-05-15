import Ember from 'ember';

export default Ember.Component.extend({
  open: true,
  classNames: ['left-drawer-page'],
  classNameBindings: ['open:left-drawer-open:left-drawer-closed'],

  actions: {
    toggle() {
      this.set('open', !this.get('open'));
    }
  }
});
