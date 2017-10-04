import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: '',

  propTypes: {
    errors: PropTypes.array,
    hideErrors: PropTypes.bool
  },
});
