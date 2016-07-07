import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['well'],

  authorEmail: Ember.computed.alias('task.paper.creator.email'),
  decisionTemplates: Ember.computed('task.letterTemplates.[]', function() {
    return this.get('task.letterTemplates').map(function(letterTemplate) {
      return {
        id: letterTemplate.get('text'),
        text: letterTemplate.get('text')
      };
    });
  }),

  inputClassNames: ['form-control']
});
