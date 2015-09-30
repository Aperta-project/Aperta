import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  trueText: "Yes",
  falseText: "No",

  answerText: Ember.computed("model", function(){
    let answer = this.get("model.answer");
    if(answer.get("wasAnswered")){
      if(answer.get("isBoolean")){
        return this._booleanAnswerText(answer);
      } else {
        return answer.get("value");
      }
    }
    return "";
  }),

  _booleanAnswerText: function(answer){
    if(answer.get("value")){
      return this.get("trueText");
    } else {
      return this.get("falseText");
    }
  }
});
