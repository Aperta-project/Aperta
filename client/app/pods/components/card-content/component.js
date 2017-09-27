// This component is a thin layer around the card-content components;
// it takes a card-content and displays the right component to view
// that in a task. To change which component goes with which content
// type, edit client/lib/card-content-types.js

import Ember from 'ember';
import CardContentTypes from 'tahi/lib/card-content-types';
import { PropTypes } from 'ember-prop-types';
import { timeout, task as concurrencyTask } from 'ember-concurrency';
import findNearestProperty from 'tahi/lib/find-nearest-property';

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
    preview: PropTypes.bool.isRequired,
    hasAnswerContainer: PropTypes.bool,
    answerChanged: PropTypes.any,
    repetition: PropTypes.EmberObject.isRequired
  },

  keepAnswerContainer: Ember.computed('content', function(){
    return !this.get('content.overrideAnswerContainer') &&
      this.get('hasAnswerContainer') &&
      (this.get('allowAnnotations') || this.get('content.instructionText'));
  }),

  getDefaultProps() {
    return {
      preview: false,
      hasAnswerContainer: true
    };
  },

  tagName: '',
  debouncePeriod: 200, // in ms

  scenario: null,
  computedScenario: Ember.computed(function() {
    return findNearestProperty(this, 'scenario');
  }),

  init() {
    this._super(...arguments);
    Ember.assert(
      `you must pass an owner to card-content`,
      Ember.isPresent(this.get('owner'))
    );
    Ember.assert(
      'this component must have content with a contentType',
      this.get('content.contentType')
    );
  },

  answer: Ember.computed('content', 'owner', 'repetition', function() {
    let answer = this.get('content').answerForOwner(this.get('owner'), this.get('repetition'));
    // if in preview mode set default values on components
    // that are answerable
    if(this.get('preview') && answer) {
      answer.set('value', this.get('content.defaultAnswerValue'));
    }
    return answer;
  }),

  _debouncedSave: concurrencyTask(function*() {
    yield timeout(this.get('debouncePeriod'));
    let answer = this.get('answer');
    return yield answer.save();
  }).restartable(),

  actions: {
    updateAnswer(newVal) {
      this.set('answer.value', newVal);
      if (this.get('answerChanged')) {
        this.get('answerChanged')(this.get('answer'));
      }
      if (this.get('preview')) {
        return;
      }
      this.get('_debouncedSave').perform();
    },

    updateAnnotation(e) {
      this.set('answer.annotation', e.target.value);
      if (!this.get('preview')) {
        this.get('_debouncedSave').perform();
      }
    }
  }
});
