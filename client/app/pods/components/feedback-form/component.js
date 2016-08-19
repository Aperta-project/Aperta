import Ember from 'ember';

export default Ember.Component.extend({
  feedbackSubmitted: false,
  isUploading: false,
  classNames: ['feedback-form'],
  close: null, //passed-in action
  remarks: null,
  allowUploads: true,
  showSuccessCheckmark: true,

  screenshots: Ember.computed(() => []),

  feedbackService: Ember.inject.service('feedback'),

  actions: {
    submit() {
      if(this.get('isUploading')) { return; }

      this.get('feedbackService').sendFeedback(
        window.location.toString(),
        this.get('remarks'),
        this.get('screenshots')
      ).then(()=> {
        this.set('feedbackSubmitted', true);
      });
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.get('screenshots').pushObject({
        url: data,
        filename: filename
      });
    },

    uploadStarted() {
      this.set('isUploading', true);
    },

    removeScreenshot(screenshot) {
      this.get('screenshots').removeObject(screenshot);
    }
  }
});
