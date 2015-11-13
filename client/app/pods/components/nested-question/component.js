import Ember from 'ember';
import NestedQuestionProxy from 'tahi/models/nested-question-proxy';

const { assert, computed } = Ember;

export default Ember.Component.extend({
  displayQuestionText: true,
  displayQuestionAsPlaceholder: false,
  helpText: null,
  inputClassNames: null,
  disabled: false,
  noResponseText: '[No response]',
  additionalData: null,

  placeholder: null,
  textClassNames: ['question-text'],

  init(){
    this._super(...arguments);

    const ident = this.get('ident');
    const model = this.get('model');
    assert(
      'Expecting to be given an ident or a model, but wasn\'t given either',
      (ident || model)
    );

    const owner = this.get('owner');
    Ember.assert('Expecting to be given a owner, but wasn\'t', owner);

    const decision = this.get('decision');

    const question = owner.findQuestion(ident);
    assert(`Expecting to find question matching ident '${ident}' but didn't.
      Make sure the owner's questions are loaded before this
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
  },

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

  change(){
    this.save();
  },

  save(){
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
  }
});
