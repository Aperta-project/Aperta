import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  store: Ember.inject.service(),
  restless: Ember.inject.service(),
  isUploading: false,
  close: null,
  attachment: null,
  dateSent: null,
  timeSent: null,
  attachmentType: Ember.computed('attachment', function() {
    let re = /(?:\.([^.]+))?$/;
    return re.exec(this.get('attachment').filename)[1];
  }),
  dateUnavailable: Ember.computed.empty(this.get('dateSent')),
  timeUnavailable: Ember.computed.empty(this.get('timeSent')),
  linkedPaper: Ember.computed('model', function() {
    return this.get('store')
               .findRecord('paper', this.get('model').get('paper').get('id'));
  }),

  formClientValidates() {
    if (this.get('timeUnavailable')) {
      this.set('validationErrors.timeSent', 'cannot be blank');
    }
    if (this.get('dateUnavailable')) {
      this.set('validationErrors.dateSent', 'cannot be blank');
    }
    return !(this.get('timeUnavailable') &&
             this.get('dateUnavailable') &&
             this.get('isUploading'));
  },
  parseTime(timeString) {
    let timeFormat = /(\d+):(\d+)(\w+)/;
    let parts = timeString.match(timeFormat);

    let hours = /am/i.test(parts[3]) ?
        function(am) {return am < 12 ? am : 0; }(parseInt(parts[1], 10)) :
        function(pm) {return pm < 12 ? pm + 12 : 12; }(parseInt(parts[1], 10));

    let minutes = parseInt(parts[2], 10);

    return [hours, minutes];
  },

  actions: {
    dateChanged(newDate) {
      this.set('dateSent', newDate);
    },
    uploadStarted() {
      this.set('isUploading', true);
    },
    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.set('attachment', {
        date: data,
        filename: filename
      });
    },

    submit(model) {

      // Make sure date is properly formed.
      // In the Correspondence object here, what is sent is the date. However
      // the form allows people specify date and time separately. This block of
      // code makes sure to resolve this back to the datetime object which the
      // model currently understands.
      let computedDate = new Date(this.get('dateSent'));
      let timeSegments = this.parseTime(this.get('timeSent'));
      computedDate.setHours(timeSegments[0]);
      computedDate.setMinutes(timeSegments[1]);
      model.set('date', JSON.stringify(computedDate));

      // if (!this.get('formClientValidates')) { return; }
      model.save().then((response) => {
        this.clearAllValidationErrors();

        if (this.get('attachment')) {
          this.get('restless').post('/api/external_correspondence_attachment', {
            external_correspondence_attachment: {
              filename: this.get('attachment').filename,
              fileType: this.get('attachmentType'),
              src: this.get('attachment').data,
              owner_type: 'ExternalCorrespondence',
              owner_id: response.get('id'),
              paper_id: this.get('model').get('paper').get('id')
            }
          });
        }

        this.sendAction('close');
      }, (response) => {
        this.displayValidationErrorsFromResponse(response);
      }).finally(() => {
      });
    }
  }
});
