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

  selectableInstitutions: function() {
    return (this.get("institutions") || []).map(function(institution) {
      return {
        id: institution,
        text: institution
      };
    });
  }.property("institutions"),

  selectedAffiliation: function() {
    return {
      id: this.get("newAuthor.affiliation"),
      text: this.get("newAuthor.affiliation")
    };
  }.property("newAuthor"),

  selectedSecondaryAffiliation: function() {
    return {
      id: this.get("newAuthor.secondaryAffiliation"),
      text: this.get("newAuthor.secondaryAffiliation")
    };
  }.property("newAuthor"),

  actions: {
    cancelEdit: function() {
      this.resetAuthor();
      this.sendAction("hideAuthorForm");
    },

    saveNewAuthor: function() {
      this.sendAction("saveAuthor", this.get("newAuthor"));
      this.resetAuthor();
    },

    addContribution: function(name) {
      this.get("newAuthor.contributions").addObject(name);
    },

    removeContribution: function(name) {
      this.get("newAuthor.contributions").removeObject(name);
    },

    resolveContributions: function(newContributions, unmatchedContributions) {
      this.get("newAuthor.contributions").removeObjects(unmatchedContributions);
      this.get("newAuthor.contributions").addObjects(newContributions);
    }
  }
});
