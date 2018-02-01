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
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
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

  name: Ember.computed('content.ident', function() {
    let ident = this.get('content.ident');
    return Ember.isEmpty(ident) ? Ember.guidFor(this) : ident;
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
    if(this.shouldEagerlySave(answer)) {
      answer.save().then(a => {
        a.initiallyHideErrors();
      });
    }

    return answer;
  }),

  shouldEagerlySave: function(answer) {
    // Card Validations expects that requiredField questions already have an
    // associated Answer saved on the server. This means we can't allow the
    // Answer to be lazily created like most Answers.
    //
    // This is similar for content with a default value. We want to initially
    // save the record, or we won't have an answer saved for something the
    // user never changes from the default.
    if(this.get('preview')) {
      return false;
    }
    if(!(answer && answer.get('isNew'))) {
      return false;
    }
    return this.get('content.requiredField') || this.get('content.defaultAnswerValue');
  },

  _debouncedSave: concurrencyTask(function*() {
    yield timeout(this.get('debouncePeriod'));
    let answer = this.get('answer');
    return yield answer.save();
  }).keepLatest(),

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
