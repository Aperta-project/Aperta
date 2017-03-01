import Ember from 'ember';
import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';

const { computed } = Ember;

export default CardContentQuestion.extend({
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
