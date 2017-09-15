import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propsTypes: {
    invitation: PropTypes.EmberObject.required
  },

  classNames: ['invitation-header']
});
