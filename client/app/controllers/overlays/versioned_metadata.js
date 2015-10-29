import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  snapshots: Ember.computed("model", function(){
    return this.get("model.snapshots");
  })
});
