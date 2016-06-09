import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  helpText: null,
  unwrappedHelpText: null,

  namePrefix: Ember.computed(function(){
    return `${this.elementId}-${this.get('ident')}`;
  }),

  actions: {
    setAnswer(decision) {
      this.set('model.answer.value', decision);
    }
  }
});
