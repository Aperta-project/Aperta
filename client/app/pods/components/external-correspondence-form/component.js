import Ember from 'ember';

export default Ember.Component.extend({
  isUploading: false,
  close: null,
  classNames: ['external-correspondence'],
  actions: {
    uploadStarted() {},
    uploadFinished() {},
    submit() {}
  }
});
