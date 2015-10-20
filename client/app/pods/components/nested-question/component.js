import Ember from 'ember';
import NestedQuestionProxy from 'tahi/models/nested-question-proxy';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  displayQuestionText: true,
  displayQuestionAsPlaceholder: false,
  helpText: null,
  inputClassNames: null,
  disabled: false,
  noResponseText: "[No response]",

  placeholder: null,
  textClassNames: ["question-text"],

  init: function(){
    this._super.apply(this, arguments);

    let ident = this.get('ident');
    let model = this.get('model');
    Ember.assert(`Expecting to be given an ident or a model, but wasn't given either`, (ident || model));

    let owner = this.get('owner');
    Ember.assert(`Expecting to be given a owner, but wasn't`, owner);

    let decision = this.get('decision');

    let question = owner.findQuestion(ident);
    Ember.assert(`Expecting to find question matching ident '${ident}' but
      didn't. Make sure questions are in the DB and are being loaded.`,
      question
    );

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

  ident: Ember.computed('model', function(){
    return this.get('model.ident');
  }),

  questionText: Ember.computed("model", function(){
    return this.get("model.text");
  }),

  shouldDisplayQuestionText: Ember.computed('model', 'displayQuestionText', function(){
    return this.get('model') && this.get('displayQuestionText');
  }),

  change: function(){
    Ember.run.debounce(this, this._saveAnswer, this.get('model.answer'), 200);
    return false;
  },

  _saveAnswer: function(answer){
    if(answer.get("owner.isNew")){
      // no-op
    } else {
      answer.save();
    }
  }
});

export default NestedQuestionComponent;
