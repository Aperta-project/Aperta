import DS from 'ember-data';
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';

export default DS.Model.extend(CardThumbnailObserver, {
  attachments: DS.hasMany('attachment', { async: false }),
  cardThumbnail: DS.belongsTo('card-thumbnail', {
    inverse: 'task',
    async: false
  }),
  commentLooks: DS.hasMany('comment-look', {
    inverse: 'task',
    async: false
  }),
  comments: DS.hasMany('comment', { async: false }),
  paper: DS.belongsTo('paper', {
    inverse: 'tasks',
    async: false
  }),
  participations: DS.hasMany('participation', { async: false }),
  phase: DS.belongsTo('phase', {
    inverse: 'tasks',
    async: false
  }),
  questions: DS.hasMany('question', {
    inverse: 'task',
    async: false
  }),
  nestedQuestions: DS.hasMany('nested-question', {
    inverse: 'task',
    async: false,
    embedded: true
  }),

  findQuestion: function(ident){
    let pathParts = ident.split(".");
    let nestedQuestions = this.get('nestedQuestions').toArray();
    let foundQuestions = this.findQuestions(pathParts, nestedQuestions);
    return _.first(foundQuestions);
  },

  findQuestions: function(pathParts, questions){
    let currentIdent = _.first(pathParts);
    let remainingPathParts = _.rest(pathParts);
    let foundQuestions = _.select(questions, (q) => { return q.get('ident') === currentIdent; });

    if(_.isEmpty(remainingPathParts)){
      return foundQuestions;
    } else {
      return this.findQuestions(remainingPathParts, this.childrenOfQuestions(foundQuestions));
    }
  },

  childrenOfQuestions: function(questions){
    return _.flatten( _(questions).pluck("children") );
  },

  body: DS.attr(),
  completed: DS.attr('boolean'),
  isMetadataTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  paperTitle: DS.attr('string'),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  role: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string'),
});
