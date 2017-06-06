import Ember from 'ember';
import Controller from 'ember-controller';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

const {
  computed,
  computed: { equal }
} = Ember;

export default Controller.extend(PaperBase, Discussions, {
  //sent by paper-new on creation, used to show submission process 1st view
  queryParams: ['firstView'],
  downloadsVisible: false,
  showFeedbackOverlay: false,

  isGradualEngagement: equal('model.gradualEngagement', true),
  renderEngagementBanner: computed('isGradualEngagement', 'model.isWithdrawn',
    function() {
      return this.get('model.gradualEngagement') &&
        !this.get('model.isWithdrawn');
    }
  ),

  showSubmissionProcess: computed('model', 'firstView', 'isGradualEngagement',
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

  showPdfManuscript: computed('model.journal.pdfAllowed', 'model.fileType', 'model.file.status',
    function(){
      return (this.get('model.journal.pdfAllowed') &&
             (this.get('model.fileType') === 'pdf')) &&
             (this.get('model.file.status') !== 'error');
    }
  ),

  checkFileType: computed('fileType', function(){
    if (this.fileType === 'pdf') {
      return 'fa-file-pdf-o';
    }
    else {
      return 'fa-file-word-o';
    }
  }),
  
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
    },

    toggleDownloads() {
      this.toggleProperty('downloadsVisible');
    },

    showFeedbackOverlay() { 
      this.set('showFeedbackOverlay', true); 
    },

    hideFeedbackOverlay() { 
      this.set('showFeedbackOverlay', false); 
    },
  }
});
