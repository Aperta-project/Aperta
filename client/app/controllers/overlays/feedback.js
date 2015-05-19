import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen feedback-overlay',
  feedbackSubmitted: false,
  isUploading: false,

  setupModel: function() {
    this.resetModel();
    this.set('model.screenshots', []);
  }.on('init'),

  resetModel() {
    this.set('model', this.store.createRecord('feedback'));
  },

  actions: {
    submit() {
      this.set('model.referrer', window.location);
      this.get('model').save().then(()=> {
        this.set('feedbackSubmitted', true);
        this.resetModel();
      });
    },

    closeAction() {
      this.send('closeFeedbackOverlay');
      this.set('feedbackSubmitted', false);
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.get('model.screenshots').pushObject({
        url: data,
        filename: filename
      });
    },

    uploadStarted() {
      this.set('isUploading', true);
    },

    removeScreenshot(screenshot) {
      this.get('model.screenshots').removeObject(screenshot);
    }
  }
});
