import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['templateDecision:well'],
  firstDecisionTemplate: Ember.computed('decisionTemplates', function() {
    return this.get('decisionTemplates.firstObject');
  }),
  //passed-in stuff
  templateDecision: null,
  letterValue: null,
  templateSelected: null, //action

  authorEmail: Ember.computed.alias('task.paper.creator.email'),
  decisionTemplates: Ember.computed('task.letterTemplates.[]',
                                    'templateDecision', function() {
                                      return this.get('task.letterTemplates'
        ).filterBy(
        'templateDecision', this.get('templateDecision')
        ).map(function(letterTemplate) {
          return {
            id: letterTemplate.get('text'),
            text: letterTemplate.get('text'),
            to: letterTemplate.get('to'),
            subject: letterTemplate.get('subject'),
            letter: letterTemplate.get('letter')
          };
        });
  }),
  decisionTemplateCount: Ember.computed('decisionTemplates.length', function() {
    return this.get('decisionTemplates.length');
  }),
  showDropdowns: Ember.computed.gt('decisionTemplateCount', 1),
  inputClassNames: ['form-control']
});

