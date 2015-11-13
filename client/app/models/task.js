import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';

export default NestedQuestionOwner.extend(CardThumbnailObserver, {
  snapshots: DS.hasMany('snapshot', { async: true }),
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

  body: DS.attr(),
  completed: DS.attr('boolean'),
  isMetadataTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  role: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string'),
  assignedToMe: DS.attr(),

  paperTitle: Ember.computed('paper', function() {
    return this.get('paper.displayTitle');
  }),

  getSnapshotForVersion: function(majorVersion, minorVersion) {
    return this.get('snapshots').find(function(snapshot) {
      return (snapshot.get('majorVersion') === Number(majorVersion) &&
              snapshot.get('minorVersion') === Number(minorVersion));
    });
  }
});
