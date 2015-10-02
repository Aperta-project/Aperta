import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['authors-overlay-item'],
  classNameBindings: ['isHovered:__hover', 'isEditable:__editable'],
  isHovered: false,
  isDeleting: false,
  isEditing: false,

  didInsertElement() {
    if (this.get('isSubmissionTaskNotEditable')) { return; }
    this.$().hover(() => {
      this.toggleProperty('isHovered');
    });
  },

  willDestroyElement() {
    this.$().off('mouseenter mouseleave');
  },

  actions: {

    edit() {
      this.set('isEditing', true);
    },

    delete() {
      this.set('isDeleting', true);
    },

    cancelDeletion() {
      this.set('isDeleting', false);
    },

    cancelRecommendation() {
      this.get('reviewer').rollback();
      this.set('isEditing', false);
      this.clearAllValidationErrors();
    },

    saveRecommendation(recommendation) {
      recommendation.save().then(() => {
        this.set('isEditing', false);
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    confirmDeletion() {
      this.$().fadeOut(250, ()=> {
        this.get('reviewer').destroyRecord();
      });
    }
  }
});
