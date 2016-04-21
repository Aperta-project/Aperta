import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';

export default NestedQuestionOwner.extend(CardThumbnailObserver, {
  attachments: DS.hasMany('attachment', { async: true }),

  cardThumbnail: DS.belongsTo('card-thumbnail', {
    inverse: 'task',
    async: false
  }),
  commentLooks: DS.hasMany('comment-look', {
    inverse: 'task',
    async: false
  }),
  comments: DS.hasMany('comment', { async: true }),
  paper: DS.belongsTo('paper', {
    inverse: 'tasks',
    async: false
  }),
  participations: DS.hasMany('participation', { async: true }),
  phase: DS.belongsTo('phase', {
    inverse: 'tasks',
    async: true
  }),
  snapshots: DS.hasMany('snapshot', {
    inverse: 'source',
    async: true
  }),

  body: DS.attr(),
  completed: DS.attr('boolean'),
  decisions: Ember.computed.alias('paper.decisions'),
  isMetadataTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  isOnlyEditableIfPaperEditable: Ember.computed.or(
    'isMetadataTask',
    'isSubmissionTask'
  ),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string'),
  assignedToMe: DS.attr(),

  paperTitle: Ember.computed('paper', function() {
    return this.get('paper.displayTitle');
  }),

  getSnapshotForVersion: function(fullVersion) {
    return this.get('snapshots').findBy('fullVersion', fullVersion);
  },

  responseToQuestion(key) {
    return this.answerForQuestion(key)
               .get('value');
  }
});
