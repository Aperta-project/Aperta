import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import ValidateTextInput from 'tahi/mixins/validate-text-input';

export default Ember.Component.extend(ValidateTextInput, {
  classNames: ['card-content', 'card-content-paragraph-input'],
  classNameBindings: ['answer.shouldShowErrors:has-error', 'disabled:read-only'],
  attributeBindings: ['data-ident'],
  'data-ident': Ember.computed.alias('content.ident'),

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
  },

  isRichText: Ember.computed.equal('content.valueType', 'html'),

  actions: {
    valueChanged(e) {
      // super to valueChanged in ValidateTextInput mixin.
      // a text input will have a string so we give it the string. Rich text editor won't have that and needs the event
      let value = e.target ? e.target.value : e;
      this._super(value);
    }
  }
});
