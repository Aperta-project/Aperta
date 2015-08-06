import Ember from 'ember';

export default Ember.Component.extend({
  _throwDeprecationWarning: Ember.on('init', function() {
    Ember.deprecate(
      'TAHI DEPRECATION: ShowIfParent is deprecated.',
      false,
      { url: 'https://github.com/Tahi-project/tahi/wiki/Tahi-Ember-1.13-Transition-Guide#showifparent-component' }
    );
  }),

  showContent: Ember.computed.reads('initialShowState'),

  initialShowState: Ember.computed('parentView', function() {
    return this.get(this.get('propName'));
  }),

  prop: '',

  propName: Ember.computed('prop', function() {
    return 'parentView.' + this.get('prop');
  }),

  showPropDidChange(sender, key) {
    this.set('showContent', sender.get(key));
  },

  setupObserver: Ember.on('didInsertElement', function() {
    this.addObserver(this.get('propName'), this, this.showPropDidChange);
  }),

  removeObserver: Ember.on('willDestroyElement', function() {
    Ember.removeObserver(this, this.get('propName'), this, this.showPropDidChange);
  })
});
