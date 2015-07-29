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

  setNewAuthor: function() {
    if (!this.get("newAuthor")) {
      this.set("newAuthor", {contributions: []});
    }
  }.on("init"),

  resetAuthor: function() {
    if (Ember.typeOf(this.get("newAuthor")) === "object") {
      this.set("newAuthor", {contributons: []});
    } else {
      this.get("newAuthor").rollback();
    }
  },

  affiliation: function() {
    if (this.get("newAuthor.affiliation")) {
      return {
        id: this.get("newAuthor.ringgoldId"),
        name: this.get("newAuthor.affiliation")
      };
    }
  }.property("newAuthor"),

  secondaryAffiliation: function() {
    if (this.get("newAuthor.secondaryAffiliation")) {
      return {
        id: this.get("newAuthor.secondaryRinggoldId"),
        name: this.get("newAuthor.secondaryAffiliation")
      };
    }
  }.property("newAuthor"),

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

    institutionSelected: function(institution) {
      this.set("newAuthor.affiliation", institution.name);
      this.set("newAuthor.ringgoldId", institution["institution-id"]);
    },

    unknownInstitutionSelected: function(institutionName) {
      this.set("newAuthor.affiliation", institutionName);
      this.set("newAuthor.ringgoldId", "");
    },

    secondaryInstitutionSelected: function(institution) {
      this.set("newAuthor.secondaryAffiliation", institution.name);
      this.set("newAuthor.secondaryRinggoldId", institution["institution-id"]);
    },

    unknownSecondaryInstitutionSelected: function(institutionName) {
      this.set("newAuthor.secondaryAffiliation", institutionName);
      this.set("newAuthor.secondaryRinggoldId", "");
    }
  }
});
