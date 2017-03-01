import Ember from 'ember';
import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';
const { computed } = Ember;
const { equal } = computed;

export default CardContentQuestion.extend({
  helpText: null,
  unwrappedHelpText: null,
  yesLabel: 'Yes',
  yesValue: true,
  noLabel: 'No',
  noValue: false,
  displayBlockContent: false,
  yesSelected: equal('answer.value', true),
  noSelected:  equal('answer.value', false),

  namePrefix: computed(function(){
    return `${this.elementId}-${this.get('ident')}`;
  }),

  yieldingForAdditionalData: computed('answer.value', function() {
    const yes = this.get('yesSelected');
    const no  = this.get('noSelected');

    return {
      yes: yes,
      no:  no,
      none: !yes && !no,
      yieldingForAdditionalData: true
    };
  }),

  actions: {
    yesAction() { this.sendAction('yesAction'); },
    noAction()  { this.sendAction('noAction'); }
  }
});
