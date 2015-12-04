import Ember from "ember";

export default Ember.Component.extend({
  layoutName: "components/add-author-form",

  author: null,

  isOtherContributionSelected: Ember.computed("author.nestedQuestions", function(){
    let answer = this.get("author").answerForQuestion("author.contributions.other");
    if(answer){
      return answer.get("value");
    }
    return false;
  }),

  authorContributionIdents: [
    "author.contributions.conceived_and_designed_experiments",
    "author.contributions.performed_the_experiments",
    "author.contributions.analyzed_data",
    "author.contributions.contributed_tools",
    "author.contributions.contributed_writing"
  ],

  affiliation: Ember.computed("author", function() {
    if (this.get("author.affiliation")) {
      return {
        id: this.get("author.ringgoldId"),
        name: this.get("author.affiliation")
      };
    }
  }),

  secondaryAffiliation: Ember.computed("author", function() {
    if (this.get("author.secondaryAffiliation")) {
      return {
        id: this.get("author.secondaryRinggoldId"),
        name: this.get("author.secondaryAffiliation")
      };
    }
  }),

  resetAuthor() {
    this.get("author").rollback();
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction("hideAuthorForm");
    },

    saveNewAuthor() {
      this.sendAction("saveAuthor", this.get("author"));
    },

    addContribution(name) {
      this.get("author.contributions").addObject(name);
    },

    removeContribution(name) {
      this.get("author.contributions").removeObject(name);
    },

    resolveContributions(newContributions, unmatchedContributions) {
      this.get("author.contributions").removeObjects(unmatchedContributions);
      this.get("author.contributions").addObjects(newContributions);
    },

    institutionSelected(institution) {
      this.set("author.affiliation", institution.name);
      this.set("author.ringgoldId", institution["institution-id"]);
    },

    unknownInstitutionSelected(institutionName) {
      this.set("author.affiliation", institutionName);
      this.set("author.ringgoldId", "");
    },

    secondaryInstitutionSelected(institution) {
      this.set("author.secondaryAffiliation", institution.name);
      this.set("author.secondaryRinggoldId", institution["institution-id"]);
    },

    unknownSecondaryInstitutionSelected(institutionName) {
      this.set("author.secondaryAffiliation", institutionName);
      this.set("author.secondaryRinggoldId", "");
    },

    toggleOtherContribution(checkbox){
      if(!checkbox.get('checked')){
        let answer = this.get("author").answerForQuestion("author.contributions.other");
        answer.destroyRecord();
      }
    }
  }
});
