import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['adhoc-content-toolbar'],
  classNameBindings: ['active:_active', 'animationDirection'],

  active: false,
  animationDirection: '_animate-forward',

  click: function() { this.send('toggle'); },

  actions: {
    toggle: function() {
      this.set( 'animationDirection', (this.get('active') ? '_animate-backward' : '_animate-forward') );
      this.toggleProperty('active');
    }
  }
});
