import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  actions: {
    dateChanged: function(newDate){
      this.set('answer.value', newDate);
    }
  }
});
