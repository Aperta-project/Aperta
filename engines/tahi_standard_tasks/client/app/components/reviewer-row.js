import Ember from 'ember';

export default Ember.Component.extend({
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

    confirmDeletion() {
      this.$().fadeOut(250, ()=> {
        this.sendAction('delete', this.get('reviewer'));
      });
    },

    saveNewRecommendation(newRecommendation) {
      this.sendAction('saveNewRecommendation', newRecommendation);
    },

    toggleReviewerForm() {
      this.sendAction('toggleReviewerForm');
    }
  }
});
