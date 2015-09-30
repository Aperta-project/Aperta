import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';

export default NestedQuestionOwner.extend(CardThumbnailObserver, {
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
  decisions: Ember.computed("paper", function(){
    let paper = this.get("paper");
    if(!paper){
      return Ember.A();
    } else {
      return paper.get("decisions");
    }
  }),
  latestDecision: Ember.computed("decisions", function(){
    return this.get("decisions").findBy("isLatest", true);
  }),
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

  body: DS.attr(),
  completed: DS.attr('boolean'),
  isMetadataTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  paperTitle: DS.attr('string'),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  role: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string')
});
