import Ember from 'ember';
import taskComponentName from 'tahi/lib/task-component-name';

export default Ember.Helper.helper(function(params) {
  return taskComponentName(params[0]);
});
