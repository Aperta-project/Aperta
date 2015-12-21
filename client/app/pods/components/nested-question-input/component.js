import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  displayContent: true,
  inputClassNames: ["form-control tall-text-field"],
  wrapInput: true,
  clearHiddenQuestions: Ember.observer('displayContent', function() {
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
    }
  }),
  type: 'text'
});
