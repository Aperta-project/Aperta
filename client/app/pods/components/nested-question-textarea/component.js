import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
import Ember from 'ember';

export default NestedQuestionComponent.extend({
  helpText: null,
  unwrappedHelpText: null,
  displayContent: true,
  inputClassNames: ['form-control'],

  change() {
    return false; // no-op to override parent's behavior
  },

  actions: {
    updateAnswer(contents) {
      this.set('answer.value', contents);
      this.save();
    }
  },

  clearHiddenQuestions: Ember.observer('displayContent', 'disabled', function() {
    if (!this.get('disabled') && !this.get('displayContent')) {
      this.set('answer.value', '');
      this.get('answer').save();
    }
  })
});
