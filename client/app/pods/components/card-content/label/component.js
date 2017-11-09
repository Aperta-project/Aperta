import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-form-label'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
  },

  onclick() {},  // Default onclick action if none passed in

  hasLabel: Ember.computed.notEmpty('content.label'),
  hasText: Ember.computed.notEmpty('content.text'),
});
