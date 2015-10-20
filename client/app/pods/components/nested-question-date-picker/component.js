import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  actions: {
    dateChanged: function(newDate){
      let answer = this.get("model.answer");
      answer.set("value", newDate);
    }
  }
});
