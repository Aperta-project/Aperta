import Ember from 'ember';
import TaskController from "tahi/pods/paper/task/controller";

export default TaskController.extend({
  task: Ember.computed.alias("model"),
  funders: Ember.computed.alias("task.funders"),
  paper: Ember.computed.alias("task.paper"),
  receivedFunding: null,

  nestedQuestionsForNewFunder: Ember.A(),

  newFunderQuestions: Ember.on('init', function(){
    let queryParams = { type: "Funder" };
    let results = this.store.findQuery('nested-question', queryParams);
    results.then( (nestedQuestions) => {
      this.set('nestedQuestionsForNewFunder', nestedQuestions);
    });
  }),

  authorReceivedFundingQuestion: Ember.computed("model", function(){
    return this.get("model").findQuestion("author_received_funding");
  }),

  numFundersObserver: Ember.observer("funders.[]", function() {
    if (this.get("receivedFunding") === false) {
      return;
    }
    if (this.get("funders.length") > 0) {
      this.set("receivedFunding", true);
    } else {
      this.set("receivedFunding", null);
    }
  }),

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
      return this.store.createRecord('funder', {
        nestedQuestions: this.get('nestedQuestionsForNewFunder'),
        task: this.get("task")
      }).save();
    }
  }
});
