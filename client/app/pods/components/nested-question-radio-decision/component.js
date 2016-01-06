import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';
export default NestedQuestionComponent.extend({

  namePrefix: Ember.computed(function(){
    return `${this.elementId}-${this.get('ident')}`;
  }),

  actions: {
    setAnswer(decision) {
      this.set('model.answer.value', decision);
    }
  }
});
