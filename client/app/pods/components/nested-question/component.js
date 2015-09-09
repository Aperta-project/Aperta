import Ember from 'ember';

export default Ember.Component.extend({
  ident: null,

  inQuestions: [],

  question: Ember.computed(function(){
    let foundQuestions = this.findQuestions(this.pathParts(), this.inQuestions);
    return _.first(foundQuestions);
  }),

  findQuestions: function(pathParts, questions){
    let currentIdent = _.first(pathParts);
    let remainingPathParts = _.rest(pathParts);
    let foundQuestions = _.select(questions, (q) => { return q.ident === currentIdent; });

    if(_.isEmpty(remainingPathParts)){
      return foundQuestions;
    } else {
      return this.findQuestions(remainingPathParts, this.childrenOfQuestions(foundQuestions));
    }
  },

  pathParts: function(){
    return this.ident.split(".");
  },

  childrenOfQuestions: function(questions){
    return _.flatten( _(questions).pluck("children") );
  }

});
