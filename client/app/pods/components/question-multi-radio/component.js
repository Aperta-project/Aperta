import QuestionComponent from 'tahi/pods/components/question/component';

export default QuestionComponent.extend({
  actions: {
     select: function (arg) {
       this.set('model.answer', arg);
     }
  }
});
