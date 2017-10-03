import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    invitation: PropTypes.EmberObject.required
  },

  classNames: ['invitation-header']
});
