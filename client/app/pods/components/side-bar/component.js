import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'aside',
  classNames: ['sidebar'],

  actions: {

    viewCard(task){
      this.sendAction('viewCard', task)
    },

    submitPaper(){
      if (this.get('paper.allSubmissionTasksCompleted')) {
        this.get('paper').save();
        this.sendAction('showConfirmSubmitOverlay');
      }
    }
  }
});
