import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
export default NestedQuestionComponent.extend({
  placeholder: null,
  displayContent: true,

  clearHiddenQuestions: Ember.observer('displayContent', function() {
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
    }
  }),

  inputClassNames: ["form-control"]
});
