import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  helpText: null,
  unwrappedHelpText: null,
  placeholder: null,
  displayContent: true,
  inputClassNames: ['form-control'],

  clearHiddenQuestions: Ember.observer('displayContent', 'disabled', function() {
    if (!this.get('disabled') && !this.get('displayContent')) {
      this.set('answer.value', '');
      this.get('answer').save();
    }
  })
});
