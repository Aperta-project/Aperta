import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import ValidateTextInput from 'tahi/mixins/validate-text-input';

export default Ember.Component.extend(ValidateTextInput, {
  classNames: ['card-content', 'card-content-short-input'],
  attributeBindings: ['isRequired:required', 'aria-required'],
  'aria-required': Ember.computed.reads('isRequiredString'),
  hasErrors: Ember.computed.notEmpty('answer.readyIssuesArray.[]'),
  classNameBindings: ['hasErrors:has-error'],

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
      // this._super will be the valueChanged action from the ValidateTextInput mixin.
      // Since input[type=text] will pass valueChanged an event, we're going to be nice
      // and pass the mixin the string value it's expecting.
      this._super(e.target.value);
    },

    maybeHideError() {
      // Hide error message but not red border when user clicks into a blanked, but errored
      // field. There is no equivalent function for paragraph-input, as TinyMCE fires a change
      // event when focusing.
      if (Ember.isBlank(this.get('workingValue'))) {
        this.set('hideError', true);
      }
    }
  }
});
