import Ember from 'ember';
import NestedQuestionComponent from 'tahi/pods/components/nested-question/component';

export default NestedQuestionComponent.extend({
  yesLabel: 'Yes',
  yesValue: 'Yes',
  noLabel: 'No',
  noValue: 'No',

  // attrs:
  ident: null,

  selectedYield: Ember.computed('answerModel.value', 'yesValue', 'noValue', function() {
    let yes  = Ember.isEqual(this.get('answerModel.value'), this.get('yesValue'));
    let no   = Ember.isEqual(this.get('answerModel.value'), this.get('noValue'));

    return {
      yes: yes,
      no:  no,
      none: !yes && !no
    };
  }),

  actions: {
    yesAction() { this.sendAction('yesAction'); },
    noAction()  { this.sendAction('noAction'); }
  }
});
