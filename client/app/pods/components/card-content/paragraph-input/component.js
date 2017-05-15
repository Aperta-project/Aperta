import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-paragraph-input'],

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
  },

  actions: {
    valueChanged(newValue) {
      let action = this.get('valueChanged');
      if (action) {
        action(newValue);
      }
    }
  }
});
