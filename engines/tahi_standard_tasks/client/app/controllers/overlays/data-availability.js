import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  dataLocationQuestion: Ember.computed("model", function(){
    let model = this.get("model");
    Ember.assert("Expected model to be set, but it wasn't.", model);
    return model.findQuestion("data_location");
  }),

  fullyAvailableQuestion: Ember.computed("model", function(){
    let model = this.get("model");
    Ember.assert("Expected model to be set, but it wasn't.", model);
    return model.findQuestion("data_fully_available");
  }),
});
