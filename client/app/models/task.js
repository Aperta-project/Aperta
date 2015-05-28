import DS from 'ember-data';
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';

export default DS.Model.extend(CardThumbnailObserver, {
  attachments: DS.hasMany('attachment'),
  cardThumbnail: DS.belongsTo('card-thumbnail', { inverse: 'task' }),
  commentLooks: DS.hasMany('comment-look', { inverse: 'task' }),
  comments: DS.hasMany('comment'),
  paper: DS.belongsTo('paper', { inverse: 'tasks' }),
  participations: DS.hasMany('participation'),
  phase: DS.belongsTo('phase', { inverse: 'tasks' }),
  questions: DS.hasMany('question', { inverse: 'task' }),

  body: DS.attr(),
  completed: DS.attr('boolean'),
  is_metadata_task: DS.attr('boolean'),
  is_submission_task: DS.attr('boolean'),
  paperTitle: DS.attr('string'),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  role: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string')
});
