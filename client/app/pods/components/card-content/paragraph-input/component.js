import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import ValidateTextInput from 'tahi/mixins/validate-text-input';

export default Ember.Component.extend(ValidateTextInput, {
  classNames: ['card-content-paragraph-input'],
  classNameBindings: ['answer.hasErrors:has-error', 'disabled:read-only'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
  },

  isRichText: Ember.computed.equal('content.valueType', 'html')
});
