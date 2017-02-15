import Ember from 'ember';
import { timeout, task as concurrencyTask } from 'ember-concurrency';

const { Component, computed } = Ember;

// card-content-question exists to provide compatibility between the new
// CardContent models and the existing NestedQuestion rendering components.
// It's essentially a copy of the NestedQuestion component with a few changes
// around `question` and `answer`.
export default Component.extend({
  inputClassNames: null,
  debouncePeriod: 200, // in ms
  disabled: false,
  noResponseText: '[No response]',
  additionalData: null,
  store: Ember.inject.service(),

  textClassNames: ['question-text'],

  owner: null,
  question: computed('ident', 'additionalData', function() {
    let ident = this.get('ident');
    Ember.assert('Expecting to be given a ident, but wasn\'t', ident);

    let question = this.get('store').peekAll('card-content').findBy('ident',  ident)
    Ember.assert(`Expecting to find question matching ident '${ident}' but
      didn't. Make sure the owner's questions are loaded before this
      initializer is called.`,
      question
    );

    if (this.get('additionalData')) {
      question.set('additionalData', this.get('additionalData'));
    }

    return question;
  }),

  _cachedAnswer: null,
  answer: computed('owner', 'question', '_cachedAnswer.isDeleted', function() {
    let cachedAnswer = this.get('_cachedAnswer');
    if (cachedAnswer && !cachedAnswer.get('isDeleted')) { return cachedAnswer; }

    let newAnswer = this.lookupAnswer();
    this.set('_cachedAnswer', newAnswer);
    return newAnswer;
  }),

  lookupAnswer() {
    let question = this.get('question');
    if (!question) { return null; }

    return question.answerForOwner(this.get('owner'));
  },

  resetAnswer() {
    this.set('_cachedAnswer', this.lookupAnswer());
  },

  // displayQuestionText and displayQuestionAsPlaceholder are set externally.
  // internally we should read shouldDisplayQuestionText
  displayQuestionAsPlaceholder: false,
  displayQuestionText: true,

  shouldDisplayQuestionText: computed('displayQuestionText', 'displayQuestionAsPlaceholder', function() {
    return !this.get('displayQuestionAsPlaceholder') && this.get('displayQuestionText');
  }).readOnly(),

  // placeholder is passed in, but all internal stuff should use placeholderText
  placeholder: '',
  placeholderText: computed('displayQuestionAsPlaceholder', 'questionText', 'placeholder', function() {
    if (this.get('displayQuestionAsPlaceholder')) {
      return this.get('questionText');
    } else {
      return this.get('placeholder');
    }
  }).readOnly(),

  questionText: computed.reads('question.text'),

  errorPresent: computed('errors', function() {
    return !Ember.isEmpty(this.get('errors'));
  }),

  change(){
    this.save();
  },

  save(){
    return this.get('_debouncedAndThrottledSave').perform();
  },

  _debouncedAndThrottledSave: concurrencyTask(function * () {
    if(this.attrs.validate) {
      this.attrs.validate(this.get('ident'), this.get('answer.value'));
    }
    yield timeout(this.get('debouncePeriod'));
    return this.get('_throttledSave').perform();
  }).restartable(),

  _throttledSave: concurrencyTask(function * () {
    return yield this._saveAnswer(this.get('answer'));
  }).keepLatest(),

  _saveAnswer(answer){
    if(answer.get('owner.isNew')){
      // no-op
    } else if(answer.get('wasAnswered')){
      return answer.save();
    } else {
      return answer.destroyRecord().then(() => this.resetAnswer());
    }
  },

  actions: {
    save() {
      this.save();
    }
  }
});
