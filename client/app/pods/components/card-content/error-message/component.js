import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    scenario: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool.isRequired
  }
});
