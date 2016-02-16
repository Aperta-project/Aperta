import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
export default NestedQuestionComponent.extend({
  placeholder: null,
  displayContent: true,
  inputClassNames: ['form-control'],

  clearHiddenQuestions: Ember.observer('displayContent', 'disabled', function() {
    if (!this.get('disabled') && !this.get('displayContent')) {
      this.set('model.answer.value', '');
      this.get('model.answer').save();
    }
  })
});
