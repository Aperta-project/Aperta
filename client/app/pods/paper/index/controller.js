import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,{
  //sent by paper-new on creation, used to show submission process 1st view
  queryParams: ['firstView'],

  isGradualEngagement: Ember.computed.equal('model.gradualEngagement', true),

  submissionProcessDisplay: Ember.computed('showSubmissionProcess', function(){
    return (this.get('showSubmissionProcess')) ? 'block' : 'none';
  }),

  showSubmissionProcess: Ember.computed('model', 'firstView', 'isGradualEngagement', function() {
    if (!this.get('isGradualEngagement')) return false;

    if (this.get('firstView') === 'true' ) {
      this.set('firstView', undefined); //removes from url
      return true;
    }
  }),
  actions: {
    toggleSubmissionProcess(){
      $('#submission-process').slideToggle(300)
    },
  },
});
