import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('admin-journal', { async: false }),
  phaseTemplates: DS.hasMany('phase-template', { async: false }),
  paperType: DS.attr('string')
});
