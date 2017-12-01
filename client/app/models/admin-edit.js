import DS from 'ember-data';
export default DS.Model.extend({
  notes: DS.attr('string'),
  active: DS.attr('boolean'),
  reviewerReport: DS.belongsTo('reviewer-report'),
  user: DS.belongsTo('user'),
  updatedAt: DS.attr('date')
});
