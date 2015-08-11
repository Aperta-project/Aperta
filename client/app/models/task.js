import Ember from 'ember';
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

  body: DS.attr(),
  completed: DS.attr('boolean'),
  isMetadataTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  paperTitle: DS.attr('string'),
  qualifiedType: DS.attr('string'),
  role: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string'),

  position: Ember.computed('phase.taskPositions.[]', function() {
    return this.get('phase.taskPositions').indexOf(this.get('id'));
  }),

});
