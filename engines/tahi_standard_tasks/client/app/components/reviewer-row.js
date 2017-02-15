import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import { task as concurrencyTask } from 'ember-concurrency';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['author-task-item', 'reviewer'],
  classNameBindings: ['isEditable:__editable'],
  isDeleting: false,
  isEditing: false,

  loadCard: concurrencyTask( function * () {
    let model = this.get('reviewerRecommendation');
    yield Ember.RSVP.all([
      model.get('card'),
      model.get('answers')
    ]);
  }),

  actions: {

    delete() {
      this.set('isDeleting', true);
    },

    cancelDeletion() {
      this.set('isDeleting', false);
    },

    cancelRecommendation(recommendation) {
      recommendation.rollbackAttributes();
      this.get('reviewerRecommendation').clearAllValidationErrors();
      this.get('toggleExpanded')();
    },

    saveRecommendation(recommendation) {
      recommendation.save().then(() => {
        this.get('reviewerRecommendation').clearAllValidationErrors();
        this.get('toggleExpanded')();
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    confirmDeletion() {
      this.$().fadeOut(250, ()=> {
        this.get('reviewerRecommendation.object').destroyRecord();
      });
    }
  }
});
