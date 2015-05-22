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

  attachmentUrl: function() {
    return '/api/figures/' + this.get('attachment.id') + '/update_attachment';
  }.property('attachment.id'),

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

    toggleEditState(focusSelector) {
      this.toggleProperty('editState');
      if (this.get('editState')) {
        this.focusOnFirstInput();
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
        this.sendAction('destroyAttachment', _this.get('attachment'));
      });
    },

    uploadStarted(data, fileUploadXHR) {
      this.sendAction('uploadStarted', data, fileUploadXHR);
    },

    uploadProgress(data) {
      this.sendAction('uploadProgress', data);
    },

    uploadFinished(data, filename) {
      this.sendAction('uploadFinished', data, filename);
    },

    togglePreview() {
      this.toggleProperty('previewState');
      if (this.get('previewState')) {
        this.scrollToView();
      }
    }
  }
});
