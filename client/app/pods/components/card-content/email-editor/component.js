import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['card-content', 'card-content-email-editor'],
  firstDecisionTemplate: Ember.computed.reads('decisionTemplates.firstObject'),
  //passed-in stuff
  category: null,
  letterValue: null,
  updateTemplate: null,
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    owner: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    answer: PropTypes.EmberObject.isRequired
  },

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
