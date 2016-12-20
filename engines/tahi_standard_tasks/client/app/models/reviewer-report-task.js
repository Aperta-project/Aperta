import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  paperReview: DS.belongsTo('paperReview'),
  decisions: DS.hasMany('decision'),
  isSubmitted: DS.attr('boolean')
});
