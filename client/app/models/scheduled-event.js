import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  state: DS.attr('string'),
  dispatchAt: DS.attr('date'),
  reviewerReport: DS.belongsTo('reviewer-report')
});
