import Ember from "ember";

export default Ember.Component.extend({
  layoutName: "components/add-author-form",
  authorContributionOptions: [
    "Conceived and designed the experiments",
    "Performed the experiments",
    "Analyzed the data",
    "Contributed reagents/materials/analysis tools",
    "Contributed to the writing of the manuscript"
  ],

  setNewAuthor: Ember.on("init", function(){
    if (!this.get("newAuthor")) {
      this.set("newAuthor", {contributions: []});
    }
  }),

  affiliation: Ember.computed("newAuthor", function() {
    if (this.get("newAuthor.affiliation")) {
      return {
        id: this.get("newAuthor.ringgoldId"),
        name: this.get("newAuthor.affiliation")
      };
    }
  }),

  secondaryAffiliation: Ember.computed("newAuthor", function() {
    if (this.get("newAuthor.secondaryAffiliation")) {
      return {
        id: this.get("newAuthor.secondaryRinggoldId"),
        name: this.get("newAuthor.secondaryAffiliation")
      };
    }
  }),

  resetAuthor() {
    if (Ember.typeOf(this.get("newAuthor")) === "object") {
      this.set("newAuthor", {contributons: []});
    } else {
      this.get("newAuthor").rollback();
    }
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction("hideAuthorForm");
    },

    saveNewAuthor() {
      this.sendAction("saveAuthor", this.get("newAuthor"));
      this.resetAuthor();
    },

    addContribution(name) {
      this.get("newAuthor.contributions").addObject(name);
    },

    removeContribution(name) {
      this.get("newAuthor.contributions").removeObject(name);
    },

    resolveContributions(newContributions, unmatchedContributions) {
      this.get("newAuthor.contributions").removeObjects(unmatchedContributions);
      this.get("newAuthor.contributions").addObjects(newContributions);
    },

    institutionSelected(institution) {
      this.set("newAuthor.affiliation", institution.name);
      this.set("newAuthor.ringgoldId", institution["institution-id"]);
    },

    unknownInstitutionSelected(institutionName) {
      this.set("newAuthor.affiliation", institutionName);
      this.set("newAuthor.ringgoldId", "");
    },

    secondaryInstitutionSelected(institution) {
      this.set("newAuthor.secondaryAffiliation", institution.name);
      this.set("newAuthor.secondaryRinggoldId", institution["institution-id"]);
    },

    unknownSecondaryInstitutionSelected(institutionName) {
      this.set("newAuthor.secondaryAffiliation", institutionName);
      this.set("newAuthor.secondaryRinggoldId", "");
    }
  }
});
