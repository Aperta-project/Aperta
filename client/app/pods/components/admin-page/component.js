import Ember from 'ember';

export default Ember.Component.extend({
  journals: [],
  classNames: ['admin-page'],

  multipleJournals: Ember.computed('journals', function() {
    return this.get('journals.length') > 1;
  })
});
