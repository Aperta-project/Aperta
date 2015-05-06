import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'a',
  attributeBindings: ['href'],

  href: function() {
    return this.get('link') + (this.get('extension') || '');
  }.property('link')
});
