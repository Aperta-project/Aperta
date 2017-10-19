import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  attachment: null,
  close: null,
  doneUploading: false,
  isUploading: false,
  restless: Ember.inject.service(),

  timeSent: Ember.computed('model', function() {
    let start = moment();
    // rounding up the minutes to the nearest hour down
    if (start.minutes() < 30) {
      start.minutes(0);
    } else {
      start.minutes(30);
    }
    return start.format('H:mm');
  }),

  prepareModelDate() {
    let date = this.get('dateSent');
    let time = this.get('timeSent');
    let m = moment.utc(date + ' ' + time, 'MM/DD/YYYY H:m');
    this.get('model').set('date', m.local().toJSON());
  },

  validateDate() {
    let dateIsValid = moment(this.get('dateSent'), 'MM/DD/YYYY').isValid();

    if (!dateIsValid) {
      this.set('validationErrors.dateSent', 'Invalid Date. Format MM/DD/YYYY');
    }

    return dateIsValid;
  },

  validateTime() {
    let timeIsValid = moment(this.get('timeSent'), 'H:m').isValid();

    if (!timeIsValid) {
      this.set('validationErrors.timeSent', 'Invalid Time. Format H:m');
    }

    return timeIsValid;
  },

  validateMandatoryPresence() {
    // This mimics the presence validations on the client side.
    let isValid = true;
    let mandatoryFields = ['description', 'sender', 'recipients', 'body'];
    for (let i = 0; i < mandatoryFields.length; i++) {
      let mandatoryFieldValue = this.get('model.' + mandatoryFields[i]);
      if (mandatoryFieldValue === '' ||
          mandatoryFieldValue === null ||
          mandatoryFieldValue === undefined) {
        this.set('validationErrors.' + mandatoryFields[i], 'cannot be blank');
        isValid = false;
      }
    }
    return isValid;
  },

  validateFields() {
    let dateIsValid = this.validateDate();
    let timeIsValid = this.validateTime();
    let mandatoryPresence = this.validateMandatoryPresence();
    return dateIsValid &&
           timeIsValid &&
           mandatoryPresence;
  },

  actions: {
    saveContentsBody(contents) {
      this.set('model.body', contents);
    },

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

      // Client-side validations
      this.clearAllValidationErrors();
      if (!this.validateFields()) return;

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
          let postUrl = `/api/papers/${paperId}/correspondence/${correspondenceId}/attachments`;
          this.get('restless').post(postUrl, {
            url: this.get('attachment.data')
          }).then(function () {
            model.reload();
          });
        }

        this.sendAction('close');
      }, (failure) => {
        // Break the association to remove this from the index.
        model.set('paper', this.get('paper'));
        this.displayValidationErrorsFromResponse(failure);
      });
    }
  }
});
