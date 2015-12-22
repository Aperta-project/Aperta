import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('admin-journal', { async: false }),
  userRoles: DS.hasMany('user-role', { async: false }),
  flows: DS.hasMany('flow', { async: true }),

  canAdministerJournal: DS.attr('boolean'),
  canViewAssignedManuscriptManagers: DS.attr('boolean'),
  canViewAllManuscriptManagers: DS.attr('boolean'),
  canViewFlowManager: DS.attr('boolean'),
  kind: DS.attr('string'),
  name: DS.attr('string'),
  required: DS.attr('boolean'),

  destroyRecord() {
    this.get('userRoles').invoke('unloadRecord');
    this._super();
  }
});
