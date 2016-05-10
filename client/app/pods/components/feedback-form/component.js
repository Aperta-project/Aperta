import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  feedbackSubmitted: false,
  isUploading: false,
  classNames: ['feedback-form'],
  close: null, //passed-in action
  feedback: null,

  init() {
    this._super(...arguments);
    this.set('store', getOwner(this).lookup('store:main'));
    this.set('feedback', this.get('store').createRecord('feedback', {
      screenshots: []
    }));
  },

  actions: {
    submit() {
      if(this.get('isUploading')) { return; }

      this.set('feedback.referrer', window.location);
      this.get('feedback').save().then(()=> {
        this.set('feedbackSubmitted', true);
      });
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.get('feedback.screenshots').pushObject({
        url: data,
        filename: filename
      });
    },

    uploadStarted() {
      this.set('isUploading', true);
    },

    removeScreenshot(screenshot) {
      this.get('feedback.screenshots').removeObject(screenshot);
    }

  }
});
