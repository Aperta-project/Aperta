import DS from 'ember-data';
import Ember from 'ember';

const { computed } = Ember;
const { attr, belongsTo, hasMany } = DS;

export default DS.Model.extend({
  authors: hasMany('author', { async: false }),
  collaborations: hasMany('collaboration', { async: false }),
  commentLooks: hasMany('comment-look', { inverse: 'paper', async: true }),
  decisions: hasMany('decision', { async: true }),
  discussionTopics: hasMany('discussion-topic', { async: true }),
  figures: hasMany('figure', { inverse: 'paper', async: true }),
  tables: hasMany('table', {
    inverse: 'paper',
    async: false
  }),
  bibitems: hasMany('bibitem', {
    inverse: 'paper',
    async: false
  }),
  journal: belongsTo('journal', { async: true }),
  phases: hasMany('phase', { async: true }),
  paperTaskTypes: hasMany('paper-task-type', { async: true }),
  supportingInformationFiles: hasMany('supporting-information-file', {
    async: false
  }),
  versionedTexts: hasMany('versioned-text', { async: true }),
  snapshots: hasMany('snapshot', { inverse: 'paper', async: true }),
  tasks: hasMany('task', { async: true, polymorphic: true }),
  manuscriptPageTasks: hasMany('task', { async: true, polymorphic: true }),
  active: attr('boolean'),
  body: attr('string'),
  doi: attr('string'),
  editable: attr('boolean'),
  editorMode: attr('string', { defaultValue: 'html' }),
  eventName: attr('string'),
  paperType: attr('string'),
  createdAt: attr('date'),
  updatedAt: attr('date'),
  relatedAtDate: attr('date'),
  relatedUsers: attr(),
  oldRoles: attr(),
  shortTitle: attr('string'),
  status: attr('string'),
  strikingImageId: attr('string'),
  submittedAt: attr('date'),
  gradualEngagement: attr('boolean'),
  publishingState: attr('string'),
  permissionState: Ember.computed.alias('publishingState'),
  title: attr('string'),
  withdrawalReason: attr('string'),
  manuscript_id: attr('string'),

  taskSorting: ['phase.position', 'position'],
  metadataTasks: Ember.computed.filterBy('tasks', 'isMetadataTask', true),
  sortedMetadataTasks: Ember.computed.sort('metadataTasks', 'taskSorting'),

  displayTitle: computed('title', 'shortTitle', function() {
    return this.get('title') || this.get('shortTitle');
  }),

  collaborators: computed('collaborations.[]', function() {
    return this.get('collaborations').mapBy('user');
  }),

  roleList: computed('oldRoles.[]', function() {
    return this.get('oldRoles').sort().join(', ');
  }),

  latestDecision: computed('decisions.[]', function() {
    return this.get('decisions').findBy('isLatest', true);
  }),

  textForVersion(versionString) {
    let versionParts = versionString.split('.');
    return this.get('versionedTexts').find(function(version) {
      return (version.get('majorVersion') === Number(versionParts[0]) &&
              version.get('minorVersion') === Number(versionParts[1]));
    });
  },

  snapshotForTaskAndVersion(task, version) {
      return this.get('snapshots').find(function(snapshot) {
          // Compare id's to prevent needless requests to the API
          return (snapshot.get('sourceId') === task.get('id') &&
                  snapshot.get('fullVersion') === version);
      });
  },

  taskOfType(taskType) {
    return this.get('tasks').find((task) => {
      return task.constructor.modelName === taskType;
    });
  },

  isUnsubmitted: computed.equal('publishingState', 'unsubmitted'),
  isSubmitted: computed.equal('publishingState', 'submitted'),
  invitedForFullSubmission: computed.equal('publishingState', 'invited_for_full_submission'),
  isInitiallySubmitted: computed.equal('publishingState', 'initially_submitted'),
  isInRevision: computed.equal('publishingState', 'in_revision'),

  isInitialSubmission: computed.and('gradualEngagement', 'isUnsubmitted'),
  isFullSubmission: computed.and('gradualEngagement', 'invitedForFullSubmission'),

  engagementState: computed('isInitialSubmission', 'isFullSubmission', function(){
    if (this.get('isInitialSubmission')) {
      return "initial";
    }
    else if (this.get('isFullSubmission')) {
      return "full";
    }
  })
});
