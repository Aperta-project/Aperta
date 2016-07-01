import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  classNameBindings: [
    ':nested-question',
    'errorPresent:error' // errorPresent defined in NestedQuestionComponent
  ],
  displayContent: true,
  formatted: false,
  inputClassNames: ['form-control tall-text-field'],
  type: 'text',
  setDefault: false,
  defaultAnswer: Ember.computed('model.answer', function() {
    if (this.get('setDefault')) {
      this.get('model.answer.value') === undefined;
      this.get('model.answer').save();
    }
  }),
  clearHiddenQuestions: Ember.observer('displayContent', function() {
    if (!this.get('displayContent')) {
      this.set('model.answer.value', '');
      this.get('model.answer').save();
    }
  })
});
