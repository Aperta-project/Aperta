import Ember from 'ember';

export default Ember.Component.extend({
  _throwDeprecationWarning: Ember.on('init', function() {
    Ember.warn('TAHI DEPRECATION: ShowIfParent is deprecated. https://github.com/Tahi-project/tahi/wiki/Tahi-Ember-1.13-Transition-Guide#showifparent-component');
  }),

  showContent: Ember.computed.reads('initialShowState'),

  initialShowState: function() {
    return this.get(this.get('propName'));
  }.property('parentView'),

  prop: '',

  propName: function() {
    return 'parentView.' + this.get('prop');
  }.property('prop'),

  showPropDidChange(sender, key) {
    this.set('showContent', sender.get(key));
  },

  setupObserver: function() {
    this.addObserver(this.get('propName'), this, this.showPropDidChange);
  }.on('didInsertElement'),

  removeObserver: function() {
    Ember.removeObserver(this, this.get('propName'), this, this.showPropDidChange);
  }.on('willDestroyElement')
});
