import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  attachment: null,
  close: null,
  doneUploading: false,
  isUploading: false,
  restless: Ember.inject.service(),

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

      // The way Correspondence was originally serialized makes this necessary
      this.prepareModelDate();

      // Setup the association late because, any earlier and this model would
      // be added to the correspondence list as it is being created.
      model.set('paper', this.get('paper'));

      model.save().then(() => {
        this.clearAllValidationErrors();

        if (this.get('attachment')) {
          let paperId = this.get('model.paper.id');
          let correspondenceId = this.get('model.id');
          let postUrl = `/api/papers/${paperId}/correspondence/${correspondenceId}/attachment`;
          this.get('restless').post(postUrl, {
            url: this.get('attachment.data')
          });
        }
        
        this.sendAction('close');
      }, (failure) => {
        this.displayValidationErrorsFromResponse(failure);
      });
    }
  }
});
