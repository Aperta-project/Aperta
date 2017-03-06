import Ember from 'ember';
import {PropTypes} from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject
  },

  classNames: ['admin-card-editor']
});
