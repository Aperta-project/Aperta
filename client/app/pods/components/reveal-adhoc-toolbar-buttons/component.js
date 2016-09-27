import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['adhoc-content-toolbar'],
  classNameBindings: ['active:_active', 'animationDirection'],

  active: false,
  disabled: false,
  animationDirection: '_animate-forward',

  click() {
    if (!this.get('disabled')) {
      this.send('toggle');}
  },

  actions: {
    toggle() {
      this.set( 'animationDirection', (this.get('active') ? '_animate-backward' : '_animate-forward') );
      this.toggleProperty('active');
    }
  }
});
