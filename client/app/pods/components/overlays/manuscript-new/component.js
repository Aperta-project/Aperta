import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';
import EscapeListenerMixin from 'tahi/mixins/overlay-escape-listener';

const { computed } = Ember;

export default Ember.Component.extend(FileUploadMixin, EscapeListenerMixin, {
  //store: Ember.inject.service(),

  journals: null,
  paper: null,
  isSaving: false,

  journalEmpty: computed.empty('paper.journal'),

  _getData: Ember.on('init', function() {
    // replace with store service when on Ember-Data 1.0+
    const store = this.container.lookup('store:main');

    const journals = store.find('journal');
    const paper = store.createRecord('paper', {
      journal: null,
      paperType: null,
      editable: true,
      body: ''
    });

    this.setProperties({
      journals: journals,
      paper: paper,
      isLoading: true
    });

    journals.then(()=> {
      this.set('isLoading', false);
    });
  }),

  titleCharCount: computed('paper.title', function() {
    return Ember.$('<div></div>')
                .append(this.get('paper.title'))
                .text().length;
  }),

  manuscriptUploadUrl: computed('paper.id', function() {
    return '/api/papers/' + this.get('paper.id') + '/upload';
  }),

  actions: {
    createPaperWithUpload() {
      if(this.get('isSaving')) { return; }

      this.set('isSaving', true);

      return this.get('paper').save().then(()=> {
        this.get('uploadFunction')();
      }, (response)=> {
        this.set('isSaving', false);
        this.flash.displayErrorMessagesFromResponse(response);
      });
    },

    selectJournal(journal) {
      this.set('paper.journal', journal);
      this.set('paper.paperType', null);
    },

    clearJournal() {
      this.set('paper.journal', null);
      this.set('paper.paperType', null);
    },

    selectPaperType(paperType) {
      this.set('paper.paperType', paperType);
    },

    clearPaperType() {
      this.set('paper.paperType', null);
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
      this.transitionToRoute('paper.index', this.get('model'));
    },

    closeOverlay() {
      this.attrs.close();
    }
  }
});
