import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({

  initialDecision: Ember.computed.alias('model.paper.decisions.firstObject'),
  isSavingData: Ember.computed.alias('initialDecision.isSaving'),
  paper: Ember.computed.alias('model.paper'),
  isPaperSubmitted: Ember.computed.equal('paper.publishingState', 'submitted'),
  isTaskCompleted: Ember.computed.equal('model.completed', true),
  isTaskUncompleted: Ember.computed.not('isTaskCompleted'),
  publishable: Ember.computed.and('isPaperSubmitted', 'isTaskUncompleted'),
  nonPublishable: Ember.computed.not('publishable'),
  hasNoLetter: Ember.computed.empty('initialDecision.letter'),
  hasNoVerdict: Ember.computed.none('initialDecision.verdict'),
  cannotRegisterDecision: Ember.computed.or('hasNoLetter', 'hasNoVerdict'),

  actions: {

    registerDecision() {

    },

    setInitialDecisionVerdict(decision) {
      this.get("initialDecision").set("verdict", decision)
    }
  }
});
