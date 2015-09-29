import Ember from "ember";

export default Ember.Component.extend({

  setNewRecommendation: Ember.on("init", function(){
    if (!this.get("newRecommendation")) {
      this.set("newRecommendation", {});
    }
  }),

  resetForm() {
    this.set('newRecommendation', {});
    // this.clearAllValidationErrors();
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
      // this.resetForm();
    }
  }
});
