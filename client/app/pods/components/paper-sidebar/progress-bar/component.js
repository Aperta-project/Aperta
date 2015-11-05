import Ember from 'ember';

export default Ember.Component.extend({
  right: Ember.computed('percent', function() {
    return 100 - this.get('percent');
  }),
});
