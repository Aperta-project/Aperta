import Ember from 'ember';
import NestedQuestionProxy from 'tahi/models/nested-question-proxy';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  tagName: 'div',
  displayQuestionText: true,
  helpText: null,
  inputClassNames: null,
  disabled: false,
  noResponseText: "[No response]",
  textClassNames: ["question-text"],

  init: function(){
    this._super.apply(this, arguments);

    let ident = this.get('ident');
    let model = this.get('model');
    Ember.assert(`Expecting to be given an ident or a model, but wasn't given either`, (ident || model));

    let task = this.get('task');
    Ember.assert(`Expecting to be given a task, but wasn't`, task);

    let decision = this.get('decision');

    let question;
    if(decision){
      question = task.questionForIdentAndDecision(ident, decision);
      Ember.assert(`Expecting to find question matching ident '${ident}' and decision ${decision.get('id')} but didn't`, question);
    } else {
      question = task.findQuestion(ident);
      Ember.assert(`Expecting to find question matching ident '${ident}' but didn't`, question);
    }

    this.set('model', NestedQuestionProxy.create({
       nestedQuestion: question,
       owner: task,
       decision: decision
    }));
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

  additionalData: Ember.computed.alias('model.additionalData'),

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
