import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: ['destroyState:_destroy', 'editState:_edit'],

  /**
   * @property attachment
   * @type {Attachment} Ember.Data model instance
   * @default null
   * @required
   */
  attachment: null,

  confidentiality: false,
  destroyState: false,
  previewState: false,
  editState: false,
  isProcessing: Ember.computed.equal('attachment.status', 'processing'),
  showSpinner: Ember.computed.or('isProcessing', 'isUploading'),
  attachmentType: 'attachment',

  preview: Ember.computed('previewSrc', 'showSpinner', function() {
    return this.get('attachment.previewSrc') && !this.get('showSpinner');
  }),

  fileIcon: Ember.computed('previewSrc', 'showSpinner', function() {
    return !this.get('attachment.previewSrc') && !this.get('showSpinner');
  }),

  attachmentUrl: Ember.computed('attachment.id', 'figure', function() {
    let urlRoot = '/api/supporting_information_files/';

    if (this.get('attachment.task')) {
      urlRoot = '/api/tasks/' + this.get('attachment.task.id') + '/attachments/';
    }
    else if (this.get('figure')) {
      urlRoot = '/api/figures/';
    }

    return urlRoot + this.get('attachment.id') + '/update_attachment';
  }),

  onProcessingFinished: Ember.observer('isProcessing', function() {
    if (!this.get('isProcessing')) {
      this.sendAction('processingFinished');
    }
  }),

  focusOnFirstInput() {
    Ember.run.schedule('afterRender', this, function() {
      this.$('input[type=text]:first').focus();
    });
  },

  scrollToView() {
    $('.overlay').animate({
      scrollTop: this.$().offset().top + $('.overlay').scrollTop()
    }, 500);
  },

  actions: {
    cancelEditing() {
      this.set('editState', false);
      this.get('attachment').rollbackAttributes();
    },

    toggleEditState() {
      if (this.get('isEditable')) {
        this.toggleProperty('editState');
        if (this.get('editState')) {
          this.focusOnFirstInput();
        }
      }
    },

    saveAttachment() {
      this.get('attachment').save();
      this.set('editState', false);
    },

    cancelDestroyAttachment() {
      this.set('destroyState', false);
    },

    confirmDestroyAttachment() {
      this.set('destroyState', true);
    },

    destroyAttachment() {
      this.$().fadeOut(250, ()=> {
        this.sendAction('destroyAttachment', this.get('attachment'));
      });
    },

    uploadStarted(data, fileUploadXHR) {
      this.set('isUploading', true);
      this.sendAction('uploadStarted', data, fileUploadXHR);
    },

    uploadProgress(data) {
      this.sendAction('uploadProgress', data);
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.sendAction('uploadFinished', data, filename);
    },

    togglePreview() {
      this.toggleProperty('previewState');
      if (this.get('previewState')) {
        this.scrollToView();
      }
    },

    toggleStrikingImageFromCheckbox(checkbox) {
      let newValue = null;
      if (checkbox.get('checked')) {
          newValue = checkbox.get('attachment.id');
      }
      this.sendAction('strikingImageAction', newValue);
    },

    togglePublishable(checkbox) {
      var newValue = checkbox.get('attachment.publishable');
      this.set('publishable', newValue);
      this.send("saveAttachment");
    }
  }
});
