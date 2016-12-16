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

  displayQuestionAsPlaceholder: false,

  _displayQuestionText: true,
  displayQuestionText: Ember.computed('_displayQuestionText', 'displayQuestionAsPlaceholder', {
    get() {
      return !this.get('displayQuestionAsPlaceholder') && this.get('_displayQuestionText');
    },
    set(_, newVal) {
      this.set('_displayQuestionText', newVal);
      return this.get('displayQuestionText');
    }
  }),

  _placeholder: '',
  placeholder: Ember.computed('displayQuestionAsPlaceholder', 'question.text', '_placeholder', {
    get() {
      if (this.get('displayQuestionAsPlaceholder')) {
        return this.get('question.text');
      } else {
        return this.get('_placeholder');
      }
    },
    set(_, newVal) {
      this.set('_placeholder', newVal);
      return this.get('placeholder');
    }
  }),

  questionText: computed.reads('question.text'),
  shouldDisplayQuestionText: computed('displayQuestionText', function() {
    return this.get('displayQuestionText');
  }),

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

  //TODO: test that this works
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
