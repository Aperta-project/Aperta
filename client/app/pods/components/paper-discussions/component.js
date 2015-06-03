import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':sheet', 'visible:sheet--visible'],

  _animateIn: function() {
    this.set('visible', true);
  }.on('didInsertElement'),

  actions: {
    closeSheet() {
      this.sendAction('on-close');
    }
  }
});
