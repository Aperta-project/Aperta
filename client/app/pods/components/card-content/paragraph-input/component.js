import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import ValidateTextInput from 'tahi/mixins/validate-text-input';

export default Ember.Component.extend(ValidateTextInput, {
  classNames: ['card-content-paragraph-input'],
  classNameBindings: ['answer.hasErrors:has-error', 'disabled:read-only'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool
  },
  isRichText: Ember.computed.equal('content.valueType', 'html'),

  actions: {
    valueChanged(e) {
      // this._super will be the valueChanged action from the ValidateTextInput mixin.
      // Since textarea will pass valueChanged an event, we're going to be nice
      // and pass the mixin the string value it's expecting.
      // If the Rich Text Editor was the one calling the action we just pass in the html as e.
      let value = (e.target && e.target.value) || e;
      this._super(value);
    }
  }
});
