import DS from 'ember-data';
import Ember from 'ember';

const { computed } = Ember;
const { attr, belongsTo, hasMany } = DS;

const PAPER_SUBMITTABLE_STATES = [
  'unsubmitted',
  'in_revision',
  'invited_for_full_submission'
];

const PAPER_GRADUAL_ENGAGEMENT_STATES = [
  'unsubmitted',
  'initially_submitted', // different than submittable states
  'invited_for_full_submission'
];

export default DS.Model.extend({
  authors: hasMany('author', { async: false }),
  collaborations: hasMany('collaboration', { async: false }),
  commentLooks: hasMany('comment-look', { inverse: 'paper', async: true }),
  decisions: hasMany('decision', { async: true }),
  discussionTopics: hasMany('discussion-topic', { async: true }),
  figures: hasMany('figure', { inverse: 'paper', async: true }),
  groupAuthors: hasMany('group-author', { async: false }),
  journal: belongsTo('journal', { async: true }),
  manuscriptPageTasks: hasMany('task', { async: true, polymorphic: true }),
  paperTaskTypes: hasMany('paper-task-type', { async: true }),
  phases: hasMany('phase', { async: true }),
  relatedArticles: hasMany('related-article', { async: true }),
  snapshots: hasMany('snapshot', { inverse: 'paper', async: true }),
  supportingInformationFiles: hasMany('supporting-information-file', {
    async: false
  }),
  tables: hasMany('table', {
    inverse: 'paper',
    async: false
  }),
  tasks: hasMany('task', { async: true, polymorphic: true }),
  versionedTexts: hasMany('versioned-text', { async: true }),

  active: attr('boolean'),
  body: attr('string'),
  coverEditors: attr(),
  createdAt: attr('date'),
  doi: attr('string'),
  editable: attr('boolean'),
  editorMode: attr('string', { defaultValue: 'html' }),
  eventName: attr('string'),
  gradualEngagement: attr('boolean'),
  handlingEditors: attr(),
  manuscript_id: attr('string'),
  oldRoles: attr(),
  paperType: attr('string'),
  permissionState: computed.alias('publishingState'),
  processing: attr('boolean'),
  publishingState: attr('string'),
  relatedAtDate: attr('date'),
  relatedUsers: attr(),
  shortTitle: attr('string'),
  status: attr('string'),
  strikingImageId: attr('string'),
  submittedAt: attr('date'),
  title: attr('string'),
  updatedAt: attr('date'),
  withdrawalReason: attr('string'),
  url: attr('string'),

  allAuthorsUnsorted: computed.union('authors', 'groupAuthors'),
  allAuthorsSortingAsc: ['position:asc'],
  allAuthors: computed.sort('allAuthorsUnsorted', 'allAuthorsSortingAsc'),

  taskSorting: ['phase.position', 'position'],
  metadataTasks: computed.filterBy('tasks', 'isMetadataTask', true),
  sortedMetadataTasks: computed.sort('metadataTasks', 'taskSorting'),

  submissionTasks: computed.filterBy('tasks', 'isSubmissionTask', true),
  sortedSubmissionTasks: computed.sort('submissionTasks', 'taskSorting'),

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

  // Submission-related stuff
  allSubmissionTasksCompleted: computed(
    'submissionTasks.@each.completed',
    function() {
      return this.get('submissionTasks').isEvery('completed', true);
    }
  ),
  isInSubmittableState: computed(
    'publishingState',
    function() {
      return PAPER_SUBMITTABLE_STATES.contains(this.get('publishingState'));
    }
  ),

  isReadyForSubmission: computed(
    'isInSubmittableState',
    'allSubmissionTasksCompleted',
    function() {
      return this.get('isInSubmittableState') && this.get('allSubmissionTasksCompleted');
    }
  ),

  isPreSubmission: computed(
    'isInSubmittableState',
    'allSubmissionTasksCompleted',
    function() {
      return this.get('isInSubmittableState') && !this.get('allSubmissionTasksCompleted');
    }
  ),

  isPendingGradualEngagementSubmission: computed(
    'publishingState',
    'gradualEngagement',
    function() {
      return PAPER_GRADUAL_ENGAGEMENT_STATES.contains(this.get('publishingState')) &&
         this.get('gradualEngagement');
    }
  ),

  isUnsubmitted: computed.equal('publishingState', 'unsubmitted'),
  isSubmitted: computed.equal('publishingState', 'submitted'),
  invitedForFullSubmission: computed.equal('publishingState', 'invited_for_full_submission'),
  isInitiallySubmitted: computed.equal('publishingState', 'initially_submitted'),
  isInRevision: computed.equal('publishingState', 'in_revision'),
  isWithdrawn: computed.equal('publishingState', 'withdrawn'),

  isInitialSubmission: computed.and('gradualEngagement', 'isUnsubmitted'),
  isFullSubmission: computed.and('gradualEngagement', 'invitedForFullSubmission'),


  engagementState: computed('isInitialSubmission', 'isFullSubmission', function(){
    if (this.get('isInitialSubmission')) {
      return "initial";
    }
    else if (this.get('isFullSubmission')) {
      return "full";
    }
  }),

  simplifiedRelatedUsers: computed.filter('relatedUsers', function(role) {
    if (role.name === 'Collaborator') {
      return false;
    }
    return true;
  })
});
