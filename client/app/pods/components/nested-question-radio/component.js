import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  yesLabel: 'Yes',
  yesValue: true,
  noLabel: 'No',
  noValue: false,
  displayBlockContent: false,
  yesSelected: Ember.computed.equal('model.answer.value', true),
  noSelected:  Ember.computed.equal('model.answer.value', false),

  namePrefix: Ember.computed(function(){
    return `${this.elementId}-${this.get('ident')}`;
  }),

  yieldingForAdditionalData: Ember.computed('model.answer.value', function() {
    let yes  = this.get('yesSelected');
    let no   = this.get('noSelected');

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
