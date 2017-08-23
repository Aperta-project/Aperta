import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: [
    'paper-preview-error-message'
  ],

  propTypes: {
    // actions:
    toggle: PropTypes.func.isRequired,
    feedback: PropTypes.func.isRequired
  },

  init() {
    this._super(...arguments);
  },

  actions: {
    toggle() {
      this.get('toggle')();
    },
    feedback() {
      this.get('feedback')();
    }
  }
});
