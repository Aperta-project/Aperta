import DS from 'ember-data';

export default DS.Model.extend({
  manuscriptManagerTemplates: DS.hasMany('manuscript-manager-template', {
    async: false
  }),
  oldRoles: DS.hasMany('old-role', { async: false }),
  journalTaskTypes: DS.hasMany('journal-task-type', { async: false }),

  createdAt: DS.attr('date'),
  description: DS.attr('string'),
  doi: DS.attr(),
  doiJournalPrefix: DS.attr('string'),
  doiPublisherPrefix: DS.attr('string'),
  lastDoiIssued: DS.attr('number'),
  logoUrl: DS.attr('string'),
  manuscriptCss: DS.attr('string'),
  name: DS.attr('string'),
  paperCount: DS.attr('number'),
  paperTypes: DS.attr(),
  pdfCss: DS.attr('string')
});
