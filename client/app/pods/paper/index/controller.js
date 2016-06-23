import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions, {
  //sent by paper-new on creation, used to show submission process 1st view
  queryParams: ['firstView'],

  isGradualEngagement: Ember.computed.equal('model.gradualEngagement', true),

  showSubmissionProcess: Ember.computed(
    'model', 'firstView', 'isGradualEngagement',
    function() {
      if (!this.get('isGradualEngagement')) return false;

      if (this.get('firstView') === 'true') {
        // Removes from url. Generally not a good idea to
        // modify a prop inside a CP. Esp since the CP is
        // watching for changes on that prop
        this.set('firstView', undefined);

        return true;
      }

      return false;
    }
  ),

  showPaperSubmitOverlay: false,

  actions: {
    toggleSubmissionProcess() {
      this.toggleProperty('showSubmissionProcess');
    },

    showPaperSubmitOverlay() {
      this.set('showPaperSubmitOverlay', true);
    },

    hidePaperSubmitOverlay() {
      this.set('showPaperSubmitOverlay', false);
    }
  }
});
