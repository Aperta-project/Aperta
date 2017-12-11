import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-view-text'],
  attributeBindings: ['data-ident'],
  'data-ident': Ember.computed.alias('content.ident'),

  hasListParent: Ember.computed.equal('content.parent.childTag', 'li'),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
  }
});
