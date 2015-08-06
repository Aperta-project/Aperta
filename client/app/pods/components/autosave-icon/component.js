import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['autosave'],
  modelIsSaving: false,
  isSaving: false,
  showCheckMark: false,

  setup: Ember.on('init', function() {
    this.set('isSaving', this.get('modelIsSaving'));
  }),

  modelIsSavingDidChange: Ember.observer('modelIsSaving', function() {
    if (this.get('modelIsSaving')) {
      this.set('isSaving', true);
    } else {
      Ember.run.later(this, function() {
        this.set('isSaving', false);
        this.set('showCheckMark', true);
        this.hideCheckMarkAfterDelay();
      }, 1000);
    }
  }),

  hideCheckMarkAfterDelay() {
    Ember.run.later(this, function() {
      this.hideCheckMark();
    }, 2000);
  },

  hideCheckMark() {
    this.set('showCheckMark', false);
  }
});
