import Ember from 'ember';
import QuestionComponent from 'tahi/pods/components/question/component';

export default QuestionComponent.extend({
  displayQuestion: null,

  checked: Ember.computed('model.answer', {
    get() {
      let answer = this.get('model.answer');
      return answer === 'true' || answer === true;
    },
    set(key, newValue) {
      return this.set('model.answer', newValue);
    }
  }),

  actions: {
    additionalDataAction() {
      this.get('additionalData').pushObject({});
    }
  }
});
