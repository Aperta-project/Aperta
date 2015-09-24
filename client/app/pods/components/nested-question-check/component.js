import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  labelClassNames: ["question-checkbox"],
  textClassNames: ["model-question"],

  additionalDataYieldValue: Ember.computed('checked', 'model.answer.value', function(){
    return { checked: this.get('checked'), yieldingForAdditionalData: true };
  }),

  textYieldValue: Ember.computed('checked', 'model.answer.value', function(){
    return { checked: this.get('checked'), yieldingForText: true };
  }),

  initCheckedValue: Ember.computed('model', function(){
    this.setCheckedValue(this.get('model.answer.value'));
  }),

  isChecked: Ember.computed('model.answer.value', function() {
    return this.get('model.answer.value');
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
