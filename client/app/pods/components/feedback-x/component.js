import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  feedbackSubmitted: false,
  isUploading: false,

  init() {
    this._super(...arguments);
    this.set('store', getOwner(this).lookup('store:main'));
    this.set('model', this.get('store').createRecord('feedback', {
      screenshots: []
    }));
  },

  actions: {
    submit() {
      if(this.get('isUploading')) { return; }

      this.set('model.referrer', window.location);
      this.get('model').save().then(()=> {
        this.set('feedbackSubmitted', true);
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
    },

    close() {
      this.attrs.close();
    }
  }
});
