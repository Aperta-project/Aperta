import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  concurrencyTask: null, // an ember-concurrency task

  propTypes: {
    concurrencyTask: PropTypes.EmberObject.isRequired
  },

  init() {
    this._super(...arguments);
    this.get('concurrencyTask').perform();
  }
});
