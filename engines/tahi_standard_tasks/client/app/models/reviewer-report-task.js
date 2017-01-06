import DecisionOwner from 'tahi/mixins/decision-owner';
import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend(DecisionOwner, {
  paperReview: DS.belongsTo('paperReview'),
  decisions: DS.hasMany('decision'),
  isSubmitted: DS.attr('boolean')
});
