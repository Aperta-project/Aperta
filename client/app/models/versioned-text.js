import DS from 'ember-data';


export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  text: DS.attr('string'),
  major_version: DS.attr(),
  minor_version: DS.attr(),
  created_at: DS.attr('date'),
  version_string: DS.attr('string')
});
