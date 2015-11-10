import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen feedback-overlay',
  feedbackSubmitted: false,
  isUploading: false,

  setupModel: Ember.on('init', function() {
    this.resetModel();
    this.set('model.screenshots', []);
  }),

  resetModel() {
    this.set('model', this.store.createRecord('feedback'));
  },

  actions: {
    submit() {
      if(this.get('isUploading')) { return; }

      this.set('model.referrer', window.location);
      this.get('model').save().then(()=> {
        this.set('feedbackSubmitted', true);
        this.resetModel();
      });
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
