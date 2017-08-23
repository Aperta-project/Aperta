import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-view-text'],

  hasListParent: Ember.computed.equal('content.parent.childTag', 'li'),

  init() {
    // we don't need the div if it's in a list
    if (this.get('hasListParent')) {
      this.set('tagName', 'span');
    }
    this._super(...arguments);
  },

  propTypes: {
    content: PropTypes.EmberObject.isRequired
  }
});
