import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  permissionModelName: 'journal',
  manuscriptManagerTemplates: DS.hasMany('manuscript-manager-template'),
  journalTaskTypes: DS.hasMany('journal-task-type', {async: false}),
  adminJournalRoles: DS.hasMany('admin-journal-role', {async: false}),
  createdAt: DS.attr('date'),
  description: DS.attr('string'),
  logoUrl: DS.attr('string'),
  manuscriptCss: DS.attr('string'),
  name: DS.attr('string'),
  paperCount: DS.attr('number'),
  paperTypes: DS.attr(),
  pdfCss: DS.attr('string'),
  pdfAllowed: DS.attr('boolean'),
  lastDoiIssued: DS.attr('string'),
  doiJournalPrefix: DS.attr('string'),
  doiPublisherPrefix: DS.attr('string'),

  // Card config:

  cards: DS.hasMany('card', {async: true}),
  initials: Ember.computed('name', function() {
    return this.get('name').split(' ').map(s => s[0]).join('');
  })
});
