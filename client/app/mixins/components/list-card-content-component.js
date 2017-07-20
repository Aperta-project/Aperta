import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Mixin.create({
  tagName: 'ul',

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    owner: PropTypes.EmberObject.isRequired,
  }
});
