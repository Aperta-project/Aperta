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

    cancelRecommendation() {
      this.get('reviewer').rollback();
      this.set('isEditing', false);
    },

    confirmDeletion() {
      this.$().fadeOut(250, ()=> {
        this.get('reviewer').destroyRecord();
      });
    }
  }
});
