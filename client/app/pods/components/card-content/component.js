// This component is a thin layer around the card-content components;
// it takes a card-content and displays the right component to view
// that in a task. To change which component goes with which content
// type, edit client/lib/card-content-types.js

import Ember from 'ember';
import CardContentTypes from 'tahi/lib/card-content-types';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  tagName: '',
  templateName: Ember.computed('content.contentType', function() {
    let type = this.get('content.contentType');
    return CardContentTypes.forType(type);
  }),

  propTypes: {
    preview: PropTypes.boolean,
    owner: PropTypes.EmberObject.isRequired
  },

  getDefaultProps() {
    return { preview: false };
  },

  init() {
    this._super(...arguments);
    // right now our ember-prop-types is only configured to print warnings,
    // not throw errors.
    Ember.assert(`you must pass an owner to card-content`,
                 Ember.isPresent(this.get('owner')));
  },

  answer: Ember.computed('content', 'owner', function() {
    return this.get('content').answerForOwner(this.get('owner'));
  }),

  actions: {
    updateAnswer(newVal) {
      this.set('answer.value', newVal);
    }
  }
});
