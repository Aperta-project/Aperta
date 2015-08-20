import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';
import FileUploadMixin from 'tahi/mixins/file-upload';

const { computed } = Ember;

export default Ember.Controller.extend(AnimateOverlay, FileUploadMixin, {
  overlayClass: 'overlay--fullscreen paper-new-overlay',
  journals: null, // set on controller before rendering overlay
  paperSaving: true,
  journalEmpty: computed.empty('model.journal'),

  shortTitleCount: computed('model.shortTitle', function() {
    let title = this.get('model.shortTitle');
    return title ? title.length : 0;
  }),

  manuscriptUploadUrl: computed('model.id', function() {
    return '/api/papers/' + this.get('model.id') + '/upload';
  }),

  actions: {
    createNewPaper() {
      if(this.get('paperSaving')) { return; }

      this.set('paperSaving', true);

      this.get('model').save().then((paper)=> {
        this.transitionToRoute('paper.edit', paper);
      }, (response)=> {
        this.flash.displayErrorMessagesFromResponse(response);
      }).finally(()=> {
        this.set('paperSaving', false);
      });
    },

    createPaperWithUpload() {
      this.set('paperSaving', true);
      this.get('model').save().then(()=> {
        this.get('uploadFunction')();
      }, (response)=> {
        this.flash.displayErrorMessagesFromResponse(response);
        this.set('paperSaving', false);
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
      this.uploadFinished(data, filename);
      this.transitionToRoute('paper.edit', this.get('model'));
    }
  }
});
