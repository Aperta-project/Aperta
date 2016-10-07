import Ember from 'ember';
import NestedQuestionComponent from
  'tahi/pods/components/nested-question/component';

const { computed } = Ember;

export default NestedQuestionComponent.extend({
  labelClassNames: ['question-checkbox'],
  textClassNames: ['model-question'],

  additionalDataYieldValue: computed('checked', 'answer.value',
    function(){
      return { checked: this.get('isChecked'),
               unchecked: this.get('isNotChecked'),
               yieldingForAdditionalData: true };
    }
  ),

  textYieldValue: computed('checked', 'answer.value', function(){
    return { checked: this.get('isChecked'),
             unchecked: this.get('isNotChecked'),
             yieldingForText: true };
  }),

  isChecked: computed.alias('answer.value'),
  isNotChecked: computed.not('isChecked'),

  setCheckedValue(checked){
    this.set('checked', checked);
    this.set('answer.value', checked);
  },

  actions: {
    checkboxToggled(checkbox){
      const checked = checkbox.get('checked');
      this.setCheckedValue(checked);
    },

    additionalDataAction() {
      this.get('additionalData').pushObject({});
    }
  }
});
