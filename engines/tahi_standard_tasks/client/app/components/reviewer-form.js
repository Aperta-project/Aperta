import Ember from "ember";
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  reviewerRecommendation: null,

  affiliation: Ember.computed("reviewerRecommendation", function() {
    if (this.get("reviewerRecommendation.affiliation")) {
      return {
        id: this.get("reviewerRecommendation.ringgoldId"),
        name: this.get("reviewerRecommendation.affiliation")
      };
    }
  }),

  actions: {

    institutionSelected(institution) {
      this.set('reviewerRecommendation.affiliation', institution.name);
      this.set('reviewerRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelRecommendation() {
      this.attrs.cancelRecommendation();
    },

    saveRecommendation() {
      this.sendAction('saveRecommendation', this.get('reviewerRecommendation'));
    }
  }
});
