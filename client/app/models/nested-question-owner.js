import DS from 'ember-data';

export default DS.Model.extend({
  nestedQuestions: DS.hasMany('nested-question', {
    inverse: 'owner',
    async: false,
  }),
  nestedQuestionAnswers: DS.hasMany('nested-question-answers', {
    inverse: 'owner',
    async: false,
  }),

  findQuestion: function(ident){
    let pathParts = ident.split(".");
    let nestedQuestions = this.get('nestedQuestions').toArray();
    let foundQuestions = this._findQuestions(pathParts, nestedQuestions);
    return _.first(foundQuestions);
  },

  _findQuestions: function(pathParts, questions){
    let currentIdent = _.first(pathParts);
    let remainingPathParts = _.rest(pathParts);
    let foundQuestions = _.select(questions, (q) => { return q.get('ident') === currentIdent; });

    if(_.isEmpty(remainingPathParts)){
      return foundQuestions;
    } else {
      return this._findQuestions(remainingPathParts, this._childrenOfQuestions(foundQuestions).toArray());
    }
  },

  _childrenOfQuestions: function(questions){
    let children =  _(questions).invoke("get", "children");
    let allTheChildren = _.invoke(children, "toArray");
    return _.flatten( allTheChildren );
  }
  
});
