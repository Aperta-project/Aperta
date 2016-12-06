import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['templateDecision:letter-template'],
  firstDecisionTemplate: Ember.computed.reads('decisionTemplates.firstObject'),
  //passed-in stuff
  templateDecision: null,
  letterValue: null,
  updateTemplate: null,

  decisionTemplates: Ember.computed(
    'task.letterTemplates.[]',
    'templateDecision',
    function() {
      return this.get('task.letterTemplates')
        .filterBy('templateDecision', this.get('templateDecision'))
        .map(function(letterTemplate) {
          return {
            id: letterTemplate.get('text'),
            text: letterTemplate.get('text')
          };
        });
    }),
  inputClassNames: ['form-control']
});
