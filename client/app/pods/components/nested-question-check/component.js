import Ember from 'ember';
import NestedQuestionComponent from
  'tahi/pods/components/nested-question/component';

const { computed } = Ember;

export default NestedQuestionComponent.extend({
  labelClassNames: ['question-checkbox'],
  textClassNames: ['model-question'],

  isChecked: computed.alias('answer.value'),

  setCheckedValue(checked){
    this.set('answer.value', checked);
  },

  actions: {
    checkboxToggled(checkbox){
      const checked = checkbox.get('checked');
      this.setCheckedValue(checked);
    }
  }
});
