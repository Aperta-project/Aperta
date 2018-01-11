import DS   from 'ember-data';
import Task from 'tahi/pods/task/model';

export default Task.extend({
  assignments: DS.hasMany('assignment', { async: false }),
  assignableRoles: DS.hasMany('assignable-role', { async: false })
});
