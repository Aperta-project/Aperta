import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  labelClassNames: ["question-checkbox"],
  textClassNames: ["model-question"],

  additionalDataYieldValue: Ember.computed('checked', 'model.answer.value', function(){
    return { checked: this.get('isChecked'),
             unchecked: this.get('isNotChecked'),
             yieldingForAdditionalData: true };
  }),

  textYieldValue: Ember.computed('checked', 'model.answer.value', function(){
    return { checked: this.get('isChecked'),
             unchecked: this.get('isNotChecked'),
             yieldingForText: true };
  }),

  isChecked: Ember.computed.alias('model.answer.value'),
  isNotChecked: Ember.computed.not('isChecked'),

  setCheckedValue: function(checked){
    let answer = this.get("model.answer");
    this.set("checked", checked);

    if(!checked){
      answer.destroyRecord();
    } else {
      answer.set("value", checked);
    }
  },

  actions: {
    checkboxToggled: function(checkbox){
      let checked = checkbox.get('checked');
      this.setCheckedValue(checked);
    },

    additionalDataAction() {
      this.get('additionalData').pushObject({});
    }
  }
});
