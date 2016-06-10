import Ember from 'ember';
import NestedQuestionProxy from 'tahi/models/nested-question-proxy';

const { Component, computed } = Ember;

export default Component.extend({
  displayQuestionText: true,
  displayQuestionAsPlaceholder: false,
  inputClassNames: null,
  disabled: false,
  noResponseText: '[No response]',
  additionalData: null,

  placeholder: null,
  textClassNames: ['question-text'],

  init(){
    this._super(...arguments);
    this.setup();
  },

  setup: Ember.observer('owner', 'ident', function() {
    const ident = this.get('ident');
    const model = this.get('model');
    Ember.assert(
      'Expecting to be given an ident or a model, but wasn\'t given either',
      (ident || model)
    );

    const owner = this.get('owner');
    if (!owner) return;
    Ember.assert('Expecting to be given a owner, but wasn\'t', owner);

    const decision = this.get('decision');

    const question = owner.findQuestion(ident);
    Ember.assert(`Expecting to find question matching ident '${ident}' but
      didn't. Make sure the owner's questions are loaded before this
      initializer is called.`,
      question
    );

    if (this.get('additionalData')) {
      question.set('additionalData', this.get('additionalData'));
    }

    this.set('model', NestedQuestionProxy.create({
       nestedQuestion: question,
       owner: owner,
       decision: decision
    }));

    if(this.get('displayQuestionAsPlaceholder')){
      this.set('displayQuestionText', false);
      this.set('placeholder', question.get('text'));
    }
  }),

  ident: computed('model', function(){
    return this.get('model.ident');
  }),

  questionText: computed('model', function(){
    return this.get('model.text');
  }),

  shouldDisplayQuestionText: computed('model', 'displayQuestionText',
    function(){
      return this.get('model') && this.get('displayQuestionText');
    }
  ),

  errorPresent: computed('errors', function() {
    return !Ember.isEmpty(this.get('errors'));
  }),

  change(){
    this.save();
  },

  save(){
    if(this.attrs.validate) {
      this.attrs.validate(this.get('ident'), this.get('model.answer.value'));
    }

    Ember.run.debounce(this, this._saveAnswer, this.get('model.answer'), 200);
    return false;
  },

  _saveAnswer(answer){
    if(answer.get('owner.isNew')){
      // no-op
    } else if(answer.get('wasAnswered')){
      answer.save();
    } else {
      answer.destroyRecord();
    }
  },

  actions: {
    save() {
      this.save();
    }
  }
});
