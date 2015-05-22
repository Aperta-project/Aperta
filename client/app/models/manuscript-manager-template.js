import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('adminJournal'),
  phaseTemplates: DS.hasMany('phaseTemplate'),
  paperType: DS.attr('string')
});
