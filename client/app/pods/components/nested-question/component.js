import Ember from 'ember';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  tagName: 'div',
  helpText: null,
  disabled: false,
  noResponseText: "[No response]",

  model: (function() {
    let ident = this.get('ident');
    Ember.assert('You must specify an ident, set to name attr', ident);

    let task = this.get('task');
    Ember.assert('You must specify a task, set to name attr', task);

    let decision = this.get('decision');
    let question;
    if(decision){
      question = task.questionForIdentAndDecision(ident, decision);
    } else {
      question = task.findQuestion(ident);
    }
    Ember.assert(`Expecting to find question matching ident '${ident}' but didn't`, question);

    return question;
  }).property('task', 'ident'),

  additionalData: Ember.computed.alias('model.additionalData'),

  change: function(){
    Ember.run.debounce(this, this._saveModel, this.get('model'), 200);
  },

  _saveModel: function(model){
    model.save();
  }
});

export default NestedQuestionComponent;
