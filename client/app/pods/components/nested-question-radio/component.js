import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  yesLabel: 'Yes',
  yesValue: true,
  noLabel: 'No',
  noValue: false,

  namePrefix: Ember.computed(function(){
    return `${this.elementId}-${this.get('ident')}`;
  }),

  yieldingForAdditionalData: Ember.computed('model.answer.value', 'yesValue', 'noValue', function() {
    let yes  = Ember.isEqual(this.get('model.answer.value'), this.get('yesValue'));
    let no   = Ember.isEqual(this.get('model.answer.value'), this.get('noValue'));

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
