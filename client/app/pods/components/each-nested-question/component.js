import Ember from 'ember';

export default Ember.Component.extend({
  in: null,

  exclude: null,

  inQuestions: [],

  questions: Ember.computed(function(){
    return _.select(this.childQuestions(), (q) => { return q.ident !== this.exclude; });
  }),

  questionsMatchingIdent: function(){
    return _.select(this.inQuestions, (q) => { return q.ident === this.in; });
  },

  childQuestions: function(){
    return _.flatten( _(this.questionsMatchingIdent()).pluck("children") );
  }

});
