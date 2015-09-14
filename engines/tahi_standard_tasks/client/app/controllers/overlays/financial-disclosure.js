import Ember from 'ember';
import TaskController from "tahi/pods/paper/task/controller";

export default TaskController.extend({
  task: Ember.computed.alias("model"),
  funders: Ember.computed.alias("task.funders"),
  paper: Ember.computed.alias("task.paper"),
  receivedFunding: null,

  numFundersObserver: (function() {
    if (this.get("receivedFunding") === false) {
      return;
    }
    if (this.get("funders.length") > 0) {
      this.set("receivedFunding", true);
      return this.set("task.questions.firstObject.answer", "Yes");
    } else {
      this.set("receivedFunding", null);
      if (this.get("task.questions.firstObject.answer")) {
        return this.set("task.questions.firstObject.answer", null);
      }
    }
  }).observes("funders.@each"),

  actions: {
    choseFundingReceived: function() {
      this.set("receivedFunding", true);
      if (this.get("funders.length") < 1) {
        return this.send("addFunder");
      }
    },

    choseFundingNotReceived: function() {
      this.set("receivedFunding", false);
      return this.get("funders").toArray().forEach(function(funder) {
        if (funder.get("isNew")) {
          return funder.deleteRecord();
        } else {
          return funder.destroyRecord();
        }
      });
    },

    addFunder: function() {
      return this.store.createRecord("funder", {
        task: this.get("task")
      }).save();
    }
  }
});
