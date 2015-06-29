import Ember from "ember";
import QuestionComponent from "tahi/pods/components/question/component";

export default QuestionComponent.extend({
  displayContent: Ember.computed.oneWay("selectedYes"),
  yesLabel: "Yes",
  noLabel: "No",
  noValue: "No",
  selectedYes: Ember.computed.equal("model.answer", "Yes"),

  changeAnswer: function() {
    this.set('model.answer', this.get('answer'));
  }.observes("answer"),

  selectedNo: function() {
    return Ember.isEqual(this.get("model.answer"), this.get("noValue"));
  }.property("model.answer", "noValue"),

  actions: {
    yesAction() {
      this.sendAction('yesAction');
    },
    noAction() {
      this.sendAction('noAction');
    }
  }
});
