import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['category:letter-template'],
  firstDecisionTemplate: Ember.computed.reads('decisionTemplates.firstObject'),
  //passed-in stuff
  category: null,
  letterValue: null,
  updateTemplate: null,

  decisionTemplates: Ember.computed(
    'task.letterTemplates.[]',
    'category',
    function() {
      return this.get('task.letterTemplates')
        .filterBy('category', this.get('category'))
        .map(function(letterTemplate) {
          return {
            id: letterTemplate.get('name'),
            text: letterTemplate.get('name')
          };
        });
    }),

  inputClassNames: ['form-control'],

  actions: {
    updateAnswer(contents) {
      this.set('letterValue', contents);
    }
  }
});
