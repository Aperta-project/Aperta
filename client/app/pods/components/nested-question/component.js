import Ember from 'ember';

const { Component, computed } = Ember;

export default Component.extend({
  inputClassNames: null,
  disabled: false,
  noResponseText: '[No response]',
  additionalData: null,

  textClassNames: ['question-text'],

  owner: null,
  question: computed('owner', 'ident', 'additionalData', function() {
    let owner = this.get('owner');
    if (!owner) return null;
    let ident=this.get('ident');
    Ember.assert('Expecting to be given a ident, but wasn\'t', this.get('ident'));
    let question = owner.findQuestion(ident);
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
  answer: computed('owner', 'question', 'decision', '_cachedAnswer.isDeleted', function() {
    let cachedAnswer = this.get('_cachedAnswer');
    if (cachedAnswer && !cachedAnswer.get('isDeleted')) { return cachedAnswer; }

    return this.resetAnswer();
  }),

  resetAnswer() {
    let question = this.get('question');
    if (!question) { return null; }
    let newAnswer =  this.get('question').answerForOwner(this.get('owner'), this.get('decision'));
    this.set('_cachedAnswer', newAnswer);
    return newAnswer;
  },

  decision: null,

  // displayQuestionText and displayQuestionAsPlaceholder are set externally.
  // internally we should read shouldDisplayQuestionText
  displayQuestionAsPlaceholder: false,
  displayQuestionText: true,

  shouldDisplayQuestionText: Ember.computed('displayQuestionText', 'displayQuestionAsPlaceholder', function() {
    return !this.get('displayQuestionAsPlaceholder') && this.get('displayQuestionText');
  }).readOnly(),

  // placeholder is passed in, but all internal stuff should use placeholderText
  placeholder: '',
  placeholderText: Ember.computed('displayQuestionAsPlaceholder', 'questionText', 'placeholder', function() {
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
    if(this.attrs.validate) {
      this.attrs.validate(this.get('ident'), this.get('answer.value'));
    }

    Ember.run.debounce(this, this._saveAnswer, this.get('answer'), 200);
    return false;
  },

  _saveAnswer(answer){
    if(answer.get('owner.isNew')){
      // no-op
    } else if(answer.get('wasAnswered')){
      answer.save();
    } else {
      answer.destroyRecord().then(() => this.resetAnswer());
    }
  },

  actions: {
    save() {
      this.save();
    }
  }
});
