import Ember from "ember";

export default Ember.Component.extend({
  unmatchedContributions: Ember.computed.setDiff("currentContributions", "availableContributions"),

  isSelected: Ember.computed.notEmpty("unmatchedContributions"),

  textValue: function() {
    return this.get("unmatchedContributions").join(", ");
  }.property("unmatchedContributions"),

  actions: {
    update: function(checkbox) {
      if(!checkbox.get("checked")) {
        this.set("textValue", "");
        this.sendAction("changed", [], this.get("unmatchedContributions"));
      }
    },

    textUpdate: function(contributionList) {
      let contributions = contributionList.split(",");

      this.sendAction("changed", contributions, this.get("unmatchedContributions"));
    }
  }
});
