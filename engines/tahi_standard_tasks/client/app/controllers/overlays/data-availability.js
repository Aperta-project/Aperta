import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  dataLocationQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("data_availability.data_location");
  }),

  fullyAvailableQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("data_availability.data_fully_available");
  }),
});
