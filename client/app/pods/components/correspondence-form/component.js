import Ember from 'ember';

export default Ember.Component.extend({
  attachment: null,
  close: null,
  doneUploading: false,
  isUploading: false,
  actions: {
    removeAttachment() {
      this.setProperties({
        doneUploading: false,
        attachment: null
      });
    },

    uploadStarted() {
      this.set('isUploading', true);
    },

    uploadFinished(_data, _filename) {
      this.setProperties({
        isUploading: false,
        doneUploading: true,
        attachment: {
          data: _data,
          filename: _filename
        }
      });
    },
    submit() {}
  }
});
