import DS from 'ember-data';


export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: true }),
  text: DS.attr('string'),
  majorVersion: DS.attr(),
  minorVersion: DS.attr(),
  createdAt: DS.attr('date'),
  versionString: DS.attr('string')
});
