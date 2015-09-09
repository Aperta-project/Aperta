import Ember from "ember";

export default Ember.Component.extend({
  isSelected: function() {
    return this.get("currentContributions").contains(this.get("value"));
  }.property("value", "contributions"),

  actions: {
    update: function(contribution) {
      if (contribution.get("checked")) {
        this.sendAction("checked", contribution.get("value"));
      } else {
        this.sendAction("unchecked", contribution.get("value"));
      }
    }
  }
});
