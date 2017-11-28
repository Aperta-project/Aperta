import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  close: null,
  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  attachments: Ember.computed.reads('model.attachments'),

  timeSent: Ember.computed('model', function() {
    let start = moment();
    // rounding down the minutes to the nearest half-hour
    if (start.minutes() < 30) {
      start.minutes(0);
    } else {
      start.minutes(30);
    }
    return start.format('H:mm');
  }),

  dateSent: Ember.computed('model', function() {
    return moment(this.get('model.date')).format('MM/DD/YYYY');
  }),

  attachmentsPath: Ember.computed('model.id', function() {
    let paperId = this.get('model.paper.id');
    let correspondenceId = this.get('model.id');
    return `/api/papers/${paperId}/correspondence/${correspondenceId}/attachments`;
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
      this.set('validationErrors.dateSent', 'Invalid Date.');
    }

    return dateIsValid;
  },

  validateTime() {
    let timeIsValid = moment(this.get('timeSent'), 'H:m').isValid();

    if (!timeIsValid) {
      this.set('validationErrors.timeSent', 'Invalid Time.');
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
        this.set('validationErrors.' + mandatoryFields[i], 'This field is required.');
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

    updateAttachment(s3Url, file, attachment) {
      attachment.set('src', s3Url);
      attachment.set('filename', file.name);
      attachment.set('title', file.name);
      if (Ember.isPresent(attachment.get('id'))) {
        attachment.save();
      }
    },

    createAttachment(s3Url, file) {
      let attachment = this.get('store').createRecord('correspondence-attachment', {
        src: s3Url,
        filename: file.name
      });
      this.get('attachments').pushObject(attachment);
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
      // 7 Nov, 2017  This component is now being reused for editing correspondence
      // thus it is necessary to check that the paper relationship doesn't exist already
      // before setting it.
      if (Ember.isEmpty(model.get('paper'))) {
        model.set('paper', this.get('paper'));
      }

      model.save().then(() => {
        this.clearAllValidationErrors();
        let attachments = this.get('attachments').filterBy('id', null);
        attachments.forEach(attachment => {
          attachment.save();
        });

        this.sendAction('close');
      }, (failure) => {
        // Break the association to remove this from the index.
        model.set('paper', this.get('paper'));
        this.displayValidationErrorsFromResponse(failure);
      });
    }
  }
});
