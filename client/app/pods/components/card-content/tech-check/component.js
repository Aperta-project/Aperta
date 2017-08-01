import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired
  },

  actions: {
    saveAnswer(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }
    }
  }
});
