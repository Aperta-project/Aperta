import Ember from "ember";
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {

  setNewRecommendation: Ember.on("init", function(){
    if (!this.get("newRecommendation")) {
      this.set("newRecommendation", {});
    }
  }),

  affiliation: Ember.computed("newRecommendation", function() {
    if (this.get("newRecommendation.affiliation")) {
      return {
        id: this.get("newRecommendation.ringgoldId"),
        name: this.get("newRecommendation.affiliation")
      };
    }
  }),

  resetForm() {
    this.set('newRecommendation', {});
    this.clearAllValidationErrors();
  },

  actions: {

    institutionSelected(institution) {
      console.log(institution);
      this.set('newRecommendation.affiliation', institution.name);
      this.set('newRecommendation.ringgoldId', institution['institution-id']);
    },

    cancel() {
      this.resetForm();
      this.sendAction('toggleReviewerForm')
    },

    save() {
      this.sendAction('saveNewRecommendation', this.get('newRecommendation'));
      this.resetForm();
    }
  }
});
