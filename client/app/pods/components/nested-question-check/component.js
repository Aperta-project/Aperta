import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  displayQuestion: null,

  textClassNames: ["model-question"],

  textYieldValue: { yieldingForText: true },

  checked: Ember.computed('model.answer.value', {
    get() {
      let answer = this.get('model.answer.value');
      return answer === 'true' || answer === true;
    },
    set(key, newValue) {
      return this.set('model.answer.value', newValue);
    }
  }),

  actions: {
    additionalDataAction() {
      this.get('additionalData').pushObject({});
    }
  }
});
