import Ember from 'ember';

export default Ember.Component.extend({
  isSaving: false,
  showCheckMark: false,

  isSavingDidChange: (function() {
    if (!this.get('isSaving')) { return; }

    this.set('showCheckMark', true);
    this.hideCheckMarkAfterDelay();
  }).observes('isSaving'),

  hideCheckMarkAfterDelay() {
    Ember.run.later(this, function() {
      this.$('.autosave-message')
          .removeClass('animation-fade-in')
          .addClass('animation-fade-out');

      Ember.run.later(this, function() {
        this.hideCheckMark();
      }, 225);
    }, 2500);
  },

  hideCheckMark() {
    this.set('showCheckMark', false);
  }
});
