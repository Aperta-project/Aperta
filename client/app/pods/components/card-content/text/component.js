import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-view-text'],

  propTypes: {
    content: PropTypes.EmberObject.isRequired
  }
});
