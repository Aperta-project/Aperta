import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-view-text'],

  isQuestionHelpListText: Ember.computed.equal('content.parent.contentType', 'question-help-list'),

  init() {
    // we don't need the div if it's in a list
    if (this.get('isQuestionHelpListText')) {
      this.set('tagName', 'span');
    }
    this._super(...arguments);
  },

  propTypes: {
    content: PropTypes.EmberObject.isRequired
  }
});
