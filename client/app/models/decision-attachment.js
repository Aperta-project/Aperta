import DS from 'ember-data';

export default DS.Model.extend({
  decision: DS.belongsTo('decision', {async: false})
});
