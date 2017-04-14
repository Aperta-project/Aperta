// This component is a thin layer around the card-content components;
// it takes a card-content and displays the right component to view
// that in a task. To change which component goes with which content
// type, edit client/lib/card-content-types.js

import Ember from 'ember';
import CardContentTypes from 'tahi/lib/card-content-types';
import { PropTypes } from 'ember-prop-types';
import { timeout, task as concurrencyTask } from 'ember-concurrency';

export default Ember.Component.extend({
  templateName: Ember.computed('content.contentType', function() {
    let type = this.get('content.contentType');
    let name = CardContentTypes.forType(type);
    return name;
  }),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    preview: PropTypes.bool
  },

  getDefaultProps() {
    return { preview: false };
  },

  tagName: '',
  debouncePeriod: 200, // in ms

  init() {
    this._super(...arguments);
    Ember.assert(`you must pass an owner to card-content`,
                 Ember.isPresent(this.get('owner')));
    Ember.assert('this component must have content with a contentType',
                 this.get('content.contentType'));
  },

  answer: Ember.computed('content', 'owner', function() {
    return this.get('content').answerForOwner(this.get('owner'));
  }),

  _debouncedSave: concurrencyTask(function * () {
    yield timeout(this.get('debouncePeriod'));
    return yield this.get('answer').save();
  }).restartable(),

  actions: {
    updateAnswer(newVal) {
      this.set('answer.value', newVal);

      if(!this.get('preview')) {
        this.get('_debouncedSave').perform();
      }
    }
  }
});
