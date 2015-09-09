import Ember from "ember";

export default Ember.Component.extend({
  layoutName: "components/add-author-form",

  setNewAuthor: Ember.on("init", function(){
    if (!this.get("newAuthor")) {
      this.set("newAuthor", {contributions: [], nestedQuestions: this.get('nestedQuestions')});
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

  otherCheckboxIsSelected: null,

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
      this.set("newAuthor", {contributons: [], nestedQuestions: this.get('nestedQuestions')});
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

    addContribution(contributionId) {
      this.get("newAuthor").addContribution(contributionId, true);
    },

    removeContribution(contributionId) {
      this.get("newAuthor").removeContribution(contributionId);
    },

    resolveContributions(newContributions, unmatchedContributions) {
      this.get("newAuthor.contributions").removeObjects(unmatchedContributions);
      this.get("newAuthor.contributions").addObjects(newContributions);
    },

    institutionSelected(institution) {
      this.set("newAuthor.affiliation", institution.name);
      this.set("newAuthor.ringgoldId", institution["institution-id"]);
    },

    otherCheckboxChanged(checkbox){
      if(checkbox.get("checked")){
        this.set("otherInfo", {value: checkbox.get("value"), textValue:""});
      } else {
        this.set("otherInfo", null);
      }
    },

    otherTextUpdated(newText){
      let author = this.get('newAuthor');
      let otherInfo = this.get('otherInfo');
      author.removeContribution(otherInfo.value);
      author.addContribution(otherInfo.value, newText);
      otherInfo.textValue = newText;
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
