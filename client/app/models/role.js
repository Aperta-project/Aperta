import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('adminJournal'),
  userRoles: DS.hasMany('userRole'),
  flows: DS.hasMany('flow', { async: true }),

  canAdministerJournal: DS.attr('boolean'),
  canViewAssignedManuscriptManagers: DS.attr('boolean'),
  canViewAllManuscriptManagers: DS.attr('boolean'),
  canViewFlowManager: DS.attr('boolean'),
  kind: DS.attr('string'),
  name: DS.attr('string'),
  required: DS.attr('boolean'),

  destroyRecord: function() {
    this.get('userRoles').invoke('unloadRecord');
    this._super();
  }
});
