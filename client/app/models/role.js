import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('journal', { async: true }),
  name: DS.attr('string')
});
