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

  destroyState: false,
  previewState: false,
  editState: false,
  isProcessing: Ember.computed.equal('attachment.status', 'processing'),
  showSpinner: Ember.computed.or('isProcessing', 'isUploading'),
  attachmentType: 'attachment',

  preview: function() {
    return this.get('attachment.previewSrc') && !this.get('showSpinner');
  }.property('previewSrc', 'showSpinner'),

  fileIcon: function() {
    return !this.get('attachment.previewSrc') && !this.get('showSpinner');
  }.property('previewSrc', 'showSpinner'),

  attachmentUrl: function() {
    if (this.get('figure')) {
      return '/api/figures/' + this.get('attachment.id') + '/update_attachment';
    } else {
      return '/api/supporting_information_files/' + this.get('attachment.id') + '/update_attachment';
    }
  }.property('attachment.id', 'figure'),

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
      this.get('attachment').rollback();
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
      var newValue = checkbox.get('checked') ? checkbox.get('attachment.id') : null;
      this.sendAction('strikingImageAction', newValue);
    }
  }
});
