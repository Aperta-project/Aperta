import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  displayQuestion: null,

  textClassNames: ["model-question"],

  additionalDataYieldValue: Ember.computed('checked', 'model.answer.value', function(){
    return { checked: this.get('checked'), yieldingForAdditionalData: true };
  }),

  textYieldValue: Ember.computed('checked', 'model.answer.value', function(){
    return { checked: this.get('checked'), yieldingForText: true };
  }),

  setCheckedValue: function(bool){
    this.set('checked', bool);
    this.set('model.answer.value', bool);
  },

  actions: {
    checkboxToggled: function(checkbox){
      this.setCheckedValue(checkbox.get('checked'));
    },

    additionalDataAction() {
      this.get('additionalData').pushObject({});
    }
  }
});
