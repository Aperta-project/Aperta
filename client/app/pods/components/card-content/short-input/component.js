import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import ValidateTextInput from 'tahi/mixins/validate-text-input';

export default Ember.Component.extend(ValidateTextInput, {
  classNames: ['card-content-short-input'],
  classNameBindings: ['answer.hasErrors:has-error'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
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
