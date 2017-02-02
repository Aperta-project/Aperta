import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'a',
  attributeBindings: ['href'],

  href: Ember.computed('link', function() {
    return this.get('link') + (this.get('extension') || '');
  })
});
