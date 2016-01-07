import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  displayContent: true,
  inputClassNames: ["form-control tall-text-field"],
  wrapInput: true,
  type: 'text',
  clearHiddenQuestions: Ember.observer('displayContent', function() {
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
      this.get('model.answer').save();
    }
  })
});
