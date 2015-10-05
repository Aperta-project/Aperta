import DS from 'ember-data';
import Ember from 'ember';

const { computed } = Ember;
const { attr, belongsTo, hasMany } = DS;

export default DS.Model.extend({
  authors: hasMany('author', { async: false }),
  collaborations: hasMany('collaboration', { async: false }),
  commentLooks: hasMany('comment-look', { inverse: 'paper', async: true }),
  decisions: hasMany('decision', { async: false }),
  editors: hasMany('user', { async: false }),
  figures: hasMany('figure', {
    inverse: 'paper',
    async: false
  }),
  tables: hasMany('table', {
    inverse: 'paper',
    async: false
  }),
  bibitems: hasMany('bibitem', {
    inverse: 'paper',
    async: false
  }),
  journal: belongsTo('journal', { async: false }),
  lockedBy: belongsTo('user', { async: false }),
  phases: hasMany('phase', { async: false }),
  reviewers: hasMany('user', { async: false }),
  supportingInformationFiles: hasMany('supporting-information-file', {
    async: false
  }),
  tasks: hasMany('task', { async: true, polymorphic: true }),

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
  roles: attr(),
  shortTitle: attr('string'),
  status: attr('string'),
  strikingImageId: attr('string'),
  submittedAt: attr('date'),
  publishingState: attr('string'),
  title: attr('string'),
  versions: attr(),
  withdrawalReason: attr('string'),

  // For diffing:
  viewingText: attr('string'),
  comparisonText: attr('string'),

  displayTitle: computed('title', 'shortTitle', function() {
    return this.get('title') || this.get('shortTitle');
  }),

  collaborators: computed('collaborations.[]', function() {
    return this.get('collaborations').mapBy('user');
  }),

  roleList: computed('roles.[]', function() {
    return this.get('roles').sort().join(', ');
  }),

  latestDecision: computed('decisions.[]', function() {
    return this.get('decisions').findBy('isLatest', true);
  })
});
