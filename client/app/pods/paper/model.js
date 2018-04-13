/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import DS from 'ember-data';
import Ember from 'ember';

const { computed } = Ember;
const { attr, belongsTo, hasMany } = DS;

const PAPER_SUBMITTABLE_STATES = [
  'unsubmitted',
  'in_revision',
  'invited_for_full_submission',
  'checking'
];

const TERMINAL_STATES = ['accepted', 'rejected'];
const DECIDABLE_STATES = ['submitted', 'initially_submitted', 'checking'];

const PAPER_GRADUAL_ENGAGEMENT_STATES = [
  'unsubmitted',
  'initially_submitted', // different than submittable states
  'invited_for_full_submission'
];

const PARTIAL_SUBMITTED_STATES = [
  'accepted',
  'rejected',
  'initially_submitted',
  'submitted',
  'published',
  'withdrawn'
];

export default DS.Model.extend({
  authors: hasMany('author', { async: false }),
  collaborations: hasMany('collaboration', { async: false }),
  commentLooks: hasMany('comment-look', { inverse: 'paper' }),
  decisions: hasMany('decision'),
  discussionTopics: hasMany('discussion-topic'),
  figures: hasMany('figure', { inverse: 'paper' }),
  groupAuthors: hasMany('group-author', { async: false }),
  journal: belongsTo('journal'),

  file: belongsTo('manuscript-attachment', { async: false}),
  sourcefile: belongsTo('sourcefile-attachment', { async: false}),

  paperTaskTypes: hasMany('paper-task-type'),
  availableCards: hasMany('card'),
  correspondences: hasMany('correspondence'),
  phases: hasMany('phase'),
  relatedArticles: hasMany('related-article'),
  snapshots: hasMany('snapshot', { inverse: 'paper' }),
  supportingInformationFiles: hasMany('supporting-information-file', {
    async: false
  }),
  tasks: hasMany('task', { polymorphic: true }),
  versionedTexts: hasMany('versioned-text'),
  similarityChecks: hasMany('similarity-check'),

  active: attr('boolean'),
  body: attr('string'),
  coverEditors: attr(),
  createdAt: attr('date'),
  creator: belongsTo('user', { async: false }),
  shortDoi: attr('string'),
  aarxDoi: attr('string'),
  aarxLink: attr('string'),
  preprintDoiSuffix: attr('string'),
  doi: attr('string'),
  editable: attr('boolean'),
  editorMode: attr('string', { defaultValue: 'html' }),
  eventName: attr('string'),
  fileType: attr('string'),
  firstSubmittedAt: attr('date'),
  gradualEngagement: attr('boolean'),
  handlingEditors: attr(),
  manuscript_id: attr('string'),
  roles: attr(),
  paperType: attr('string'),
  permissionState: computed.alias('publishingState'),
  processing: attr('boolean'),
  publishingState: attr('string'),
  relatedAtDate: attr('date'),
  relatedUsers: attr(),
  shortTitle: attr('string'),
  status: attr('string'),
  submittedAt: attr('date'),
  title: attr('string'),
  abstract: attr('string'),
  updatedAt: attr('date'),
  withdrawalReason: attr('string'),
  url: attr('string'),
  versionsContainPdf: attr('boolean'),
  legendsAllowed: attr('boolean'),
  currentUserRoles: attr(),
  manuallySimilarityChecked: attr('boolean'),
  preprintOptIn: attr('boolean'),
  preprintEligible: attr('boolean'),
  preprintDashboard: attr('boolean'),

  reviewDueAt: attr('date'),
  reviewOriginallyDueAt: attr('date'),
  reviewDurationPeriod: attr('number'),

  paper_shortDoi: computed.oneWay('shortDoi'),
  allAuthorsUnsorted: computed.union('authors', 'groupAuthors'),
  allAuthorsSortingAsc: ['position:asc'],
  allAuthors: computed.sort('allAuthorsUnsorted', 'allAuthorsSortingAsc'),

  taskSorting: ['phase.position', 'position'],
  metadataTasks: computed.filterBy('tasks', 'isMetadataTask', true),
  sortedMetadataTasks: computed.sort('metadataTasks', 'taskSorting'),

  snapshotTasks: computed.filterBy('tasks', 'isSnapshotTask', true),
  sortedSnapshotTasks: computed.sort('snapshotTasks', 'taskSorting'),

  submissionTasks: computed.filterBy('tasks', 'isSubmissionTask', true),
  sortedSubmissionTasks: computed.sort('submissionTasks', 'taskSorting'),

  displayTitle: computed('title', function() {
    return this.get('title') || '[No Title]';
  }),

  collaborators: computed('collaborations.@each.user', function() {
    return this.get('collaborations').mapBy('user');
  }),

  roleList: computed('roles.[]', function() {
    return this.get('roles').sort().join(', ');
  }),

  draftDecision: computed('decisions.@each.draft', function() {
    return this.get('decisions').findBy('draft', true);
  }),

  latestRegisteredDecision: computed(
    'decisions.@each.latestRegistered',
    function() {
      return this.get('decisions').findBy('latestRegistered', true);
    }
  ),

  previousDecisions: computed('decisions.@each.registeredAt', function() {
    return this.get('decisions')
      .rejectBy('draft')
      .sortBy('registeredAt')
      .reverseObjects();
  }),

  versionAscendingSort: ['isDraft:asc', 'majorVersion:asc', 'minorVersion:asc'],
  versionedTextsAscending: computed.sort('versionedTexts', 'versionAscendingSort'),

  latestVersionedText: computed.reads('versionedTextsAscending.lastObject'),

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
      return PAPER_SUBMITTABLE_STATES.includes(this.get('publishingState'));
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
      return PAPER_GRADUAL_ENGAGEMENT_STATES.includes(this.get('publishingState')) &&
         this.get('gradualEngagement');
    }
  ),

  isPartialSubmittedState: computed(
    'publishingState',
    function() {
      return PARTIAL_SUBMITTED_STATES.includes(this.get('publishingState'));
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

  /* True if a decision can be registered in this state. */
  isReadyForDecision: computed('publishingState', function() {
    return DECIDABLE_STATES.includes(this.get('publishingState'));
  }),

  hasAnyError: computed.equal('file.status', 'error'),
  previewFail: false,

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
  }),

  sortedDecisions: computed('decisions.@each.registeredAt', function() {
    return this.get('decisions').sortBy('registeredAt');
  }),

  initialDecision: computed(
    'decisions.@each.registeredAt',
    'decisions.@each.rescinded',
    function() {
      let decisions = this.get('sortedDecisions');
      let latestInitial = this.get('decisions')
                              .filterBy('initial')
                              .filterBy('rescinded', false)
                              .get('lastObject');
      // If there's already been a full decision
      // then just return the most recent initial decision.
      let fullDecisions = decisions.filterBy('registeredAt')
                                   .filterBy('initial', false);
      if (fullDecisions.get('length') > 0) {
        return latestInitial;
      }

      // If all other decisions have been rescinded,
      // return the latest, unmade decision
      let prevCount = decisions.filter((d) => {
        return d.get('registeredAt') && !d.get('rescinded');
      }).get('length');
      if (prevCount === 0) {
        return decisions.findBy('registeredAt', null);
      }

      return latestInitial;
    }),

  hasSimilarityChecks: computed.notEmpty('similarityChecks'),

  restless: Ember.inject.service(),

  atMentionableStaffUsers() {
    const url = '/api/at_mentionable_users';
    const data = { on_paper_id: this.get('id') };

    return this.get('restless').get(url, data).then((data)=> {
      // push the response into the DS and return a promise which resolves to
      // the records which were pushed.
      this.store.pushPayload(data);
      return _.map(data['users'], (user) => {
        return this.store.findRecord('user', user['id']);
      });
    });
  }
});
