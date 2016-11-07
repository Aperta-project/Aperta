import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('admin-journal', { async: false }),

  canAdministerJournal: DS.attr('boolean'),
  canViewAssignedManuscriptManagers: DS.attr('boolean'),
  canViewAllManuscriptManagers: DS.attr('boolean'),
  kind: DS.attr('string'),
  name: DS.attr('string'),
  required: DS.attr('boolean'),

  destroyRecord() {
    this._super();
  }
});
