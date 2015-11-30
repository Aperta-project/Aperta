import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';
import FileUploadMixin from 'tahi/mixins/file-upload';

const { computed } = Ember;

export default Ember.Controller.extend(AnimateOverlay, FileUploadMixin, {
  overlayClass: 'overlay--fullscreen paper-new-overlay',
  journals: null, // set on controller before rendering overlay
  journalEmpty: computed.empty('model.journal'),
  isSaving: false,

  titleCharCount: computed('model.title', function() {
    return Ember.$('<div></div>')
                .append(this.get('model.title'))
                .text().length;
  }),

  manuscriptUploadUrl: computed('model.id', function() {
    return '/api/papers/' + this.get('model.id') + '/upload';
  }),

  actions: {
    createPaperWithUpload() {
      if(this.get('isSaving')) { return; }

      this.set('isSaving', true);

      return this.get('model').save().then(()=> {
        this.get('uploadFunction')();
      }, (response)=> {
        this.set('isSaving', false);
        this.flash.displayErrorMessagesFromResponse(response);
      });
    },

    selectJournal(journal) {
      this.set('model.journal', journal);
      this.set('model.paperType', null);
    },

    clearJournal() {
      this.set('model.journal', null);
      this.set('model.paperType', null);
    },

    selectPaperType(paperType) {
      this.set('model.paperType', paperType);
    },

    clearPaperType() {
      this.set('model.paperType', null);
    },

    /**
     *  Called by `file-uploader` in template
     *  We're hanging on to the upload function to fire later
     *  after the paper model is saved
     *
     *  @method uploadReady
     *  @param {Function} [func] Function to trigger upload of file
     *  @public
    **/
    uploadReady(func) {
      this.set('uploadFunction', func);
      this.send('createPaperWithUpload');
    },

    /**
     *  Overrides action provided by FileUploadMixin
     *  Called by `file-uploader` in template
     *
     *  @method uploadFinished
     *  @param {Object} [data]
     *  @param {String} [filename]
     *  @public
    **/
    uploadFinished(data, filename) {
      this.set('isSaving', false);
      this.uploadFinished(data, filename);
      this.transitionToRoute('paper.index', this.get('model'), {
        queryParams: {firstView: 'true'}
      });
    }
  }
});
