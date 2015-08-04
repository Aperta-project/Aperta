import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('admin-journal'),
  phaseTemplates: DS.hasMany('phase-template'),
  paperType: DS.attr('string')
});
