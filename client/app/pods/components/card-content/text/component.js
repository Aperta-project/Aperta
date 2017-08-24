import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-view-text'],

  hasListParent: Ember.computed.equal('content.parent.childTag', 'li'),

  propTypes: {
    content: PropTypes.EmberObject.isRequired
  }
});
