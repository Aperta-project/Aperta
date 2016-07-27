import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  classNameBindings: [
    ':nested-question',
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],
  defaultAnswer: null,
  setAnswer: Ember.observer('answer', 'init',
      function() {
        if (this.get('defaultAnswer')) {
          this.set('model.answer.value', this.get('defaultAnswer'));
        }
      }.on('init')),
  displayContent: true,
  formatted: false,
  inputClassNames: ['form-control tall-text-field'],
  type: 'text',
  clearHiddenQuestions: Ember.observer('displayContent', function() {
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
      this.get('model.answer').save();
    }
  })
});
