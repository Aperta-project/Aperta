import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import ValidateTextInput from 'tahi/mixins/validate-text-input';

export default Ember.Component.extend(ValidateTextInput, {
  classNames: ['card-content', 'card-content-short-input'],
  classNameBindings: ['answer.shouldShowErrors:has-error'],
  attributeBindings: ['isRequired:required', 'aria-required', 'data-ident'],
  'aria-required': Ember.computed.reads('isRequiredString'),
  'data-ident': Ember.computed.alias('content.ident'),

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
  },

  //short-input renders a standard {{input}} component, which doesn't bind aria attributes
  didInsertElement() {
    if (this.get('content.isRequired') === true) {
      this.$('input').attr({'aria-required': 'true'});
    }
  },

  actions: {
    valueChanged(e) {
      // super to valueChanged in ValidateTextInput mixin. Pass it the field's value instead of an event
      this._super(e.target.value);
    },

    maybeHideError() {
      if (Ember.isBlank(this.get('answerProxy'))) {
        this.set('hideError', true);
      }
    }
  }
});
