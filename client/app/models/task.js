import Ember from 'ember';
import DS from 'ember-data';
import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer';
import Answerable from 'tahi/mixins/answerable';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import Snapshottable from 'tahi/mixins/snapshottable';

export default NestedQuestionOwner.extend(Answerable, CardThumbnailObserver, Snapshottable, {
  attachments: DS.hasMany('adhoc-attachment', {
    async: true,
    inverse: 'task'
  }),
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
  invitations: DS.hasMany('invitation', {
    async: false
  }),

  body: DS.attr(),
  completed: DS.attr('boolean'),
  decisions: Ember.computed.alias('paper.decisions'),
  isMetadataTask: DS.attr('boolean'),
  isSnapshotTask: DS.attr('boolean'),
  isSubmissionTask: DS.attr('boolean'),
  isOnlyEditableIfPaperEditable: Ember.computed.or(
    'isMetadataTask',
    'isSubmissionTask'
  ),
  permissionState: Ember.computed.alias('paper.permissionState'),
  position: DS.attr('number'),
  qualifiedType: DS.attr('string'),
  title: DS.attr('string'),
  type: DS.attr('string'),
  assignedToMe: DS.attr(),

  componentName: Ember.computed('type', function() {
    return Ember.String.dasherize(this.get('type'));
  }),

  paperTitle: Ember.computed('paper', function() {
    return this.get('paper.displayTitle');
  }),

  getSnapshotForVersion: function(fullVersion) {
    return this.get('snapshots').findBy('fullVersion', fullVersion);
  },

  responseToQuestion(key) {
    var questionResponse = (this.answerForIdent(key) || Ember.ObjectProxy.create());
    return questionResponse.get('value');
  },

  isSidebarTask: Ember.computed.or('assignedToMe', 'isSubmissionTask')
});
