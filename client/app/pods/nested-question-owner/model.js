import DS from 'ember-data';

export default DS.Model.extend({
  nestedQuestions: DS.hasMany('nested-question', {
    async: true
  }),
  nestedQuestionAnswers: DS.hasMany('nested-question-answers', {
    inverse: 'owner',
    async: true
  }),

  answerForQuestion(ident){
    let question = this.findQuestion(ident);
    if(question){
      return question.answerForOwner(this);
    } else {
      return null;
    }
  },

  findQuestion: function(ident){
    const nestedQuestions = this.get('nestedQuestions').toArray();
    return _.detect(nestedQuestions, (q) => { return q.get('ident') === ident; });
  }
});
