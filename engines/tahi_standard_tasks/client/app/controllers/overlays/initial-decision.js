import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

const { computed } = Ember;

export default TaskController.extend({

  restless: Ember.inject.service(),
  initialDecision: computed.alias('model.paper.decisions.firstObject'),
  isSavingData: computed.alias('initialDecision.isSaving'),
  paper: computed.alias('model.paper'),
  isTaskCompleted: computed.equal('model.completed', true),
  isTaskUncompleted: computed.not('isTaskCompleted'),
  publishable: computed.and('isPaperInitiallySubmitted', 'isTaskUncompleted'),
  nonPublishable: computed.not('publishable'),
  hasNoLetter: computed.empty('initialDecision.letter'),
  hasNoVerdict: computed.none('initialDecision.verdict'),
  isPaperInitiallySubmitted: computed.equal('paper.publishingState',
                                                  'initially_submitted'),
  cannotRegisterDecision: computed.or('hasNoLetter', 'hasNoVerdict',
                                            'isTaskCompleted'),

  verdict: computed('initialDecision.verdict', function() {
    if (this.get('initialDecision.verdict')) {
      return this.get('initialDecision.verdict').replace(/_/g, ' ');
    }
  }),

  actions: {

    registerDecision() {
      const taskId = this.get('model.id');
      this.get('initialDecision').save().then(() => {
        this.get('restless').post(`/api/initial_decision/${taskId}`).then(()=>{
          this.set('model.completed', true);
          this.get('model').save();
        });
      });
    },

    setInitialDecisionVerdict(decision) {
      this.get("initialDecision").set("verdict", decision);
    }
  }
});
