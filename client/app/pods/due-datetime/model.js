import DS from 'ember-data';

export default DS.Model.extend({
  dueAt: DS.attr('date'),
  reviewerReport: DS.belongsTo('reviewer_report'),
  scheduledEvents: DS.hasMany('scheduled_event', { async: false })
});
