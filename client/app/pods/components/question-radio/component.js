import Ember from "ember";
import QuestionComponent from "tahi/pods/components/question/component";

export default QuestionComponent.extend({
  displayContent: Ember.computed.oneWay("selectedYes"),
  yesLabel: "Yes",
  noLabel: "No",
  selectedYes: Ember.computed.equal("model.answer", "Yes"),
  selectedNo:  Ember.computed.equal("model.answer", "No")
});
