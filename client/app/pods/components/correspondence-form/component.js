import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  attachment: null,
  close: null,
  doneUploading: false,
  isUploading: false,

  prepareModelDate() {
    let date = this.get('dateSent');
    let time = this.get('timeSent');
    let m = moment.utc(date + ' ' + time, 'DD/MM/YYYY hh:mm a');
    this.get('model').set('date', m.local().toJSON());
  },

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
    submit(model) {
      if (this.get('isUploading')) return;

      this.prepareModelDate();

      model.save().then(() => {
        this.clearAllValidationErrors();
        this.sendAction('close');
      }, (failure) => {
        this.displayValidationErrorsFromResponse(failure);
      });
    }
  }
});
