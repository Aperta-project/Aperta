import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-paragraph-input'],
  classNameBindings: ['answer.hasErrors:has-error'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
  },

  isRichText: Ember.computed('content.valueType', function() {
    return (this.get('content.valueType') === 'html');
  }),

  actions: {
    valueChanged(newValue) {
      let action = this.get('valueChanged');
      if (action) {
        action(newValue);
      }
    }
  }
});
