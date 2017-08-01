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
    }
  }
});
