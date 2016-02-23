import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['authors-overlay-item'],
  classNameBindings: ['showHover:__hover', 'isEditable:__editable'],
  isDeleting: false,
  isEditing: false,

  canHover: Ember.computed.alias('isEditable'),
  isHovering: false,
  showHover: Ember.computed.and('isHovering', 'canHover'),

  _setupHover: Ember.on('didInsertElement', function(){
    this.$().hover(() => {
      this.toggleProperty('isHovering');
    });
  }),

  _destroyHover: Ember.on('willDestroyElement', function(){
    this.$().off('mouseenter mouseleave');
  }),

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
      this.get('reviewerRecommendation').rollback();
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
        this.get('reviewerRecommendation').destroyRecord();
      });
    }
  }
});
