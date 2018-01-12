import DS from 'ember-data';
import Task from 'tahi/pods/task/model';

export default Task.extend({
  funders: DS.hasMany('funder')
});
