import Ember from 'ember';

export default Ember.Component.extend({
  for: null,

  inQuestions: [],

  questions: Ember.computed(function(){
    return _.flatten(_(this.matchingQuestions()).pluck("children"));
  }),

  matchingQuestions: function(){
    return _.select(this.inQuestions, (q) => { return q.ident === this.for; });
  }
});
