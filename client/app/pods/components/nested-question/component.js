import Ember from 'ember';
import NestedQuestionProxy from 'tahi/models/nested-question-proxy';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  tagName: 'div',
  displayQuestionText: true,
  helpText: null,
  inputClassNames: null,
  disabled: false,
  textClassNames: ["question-text"],

  ident: Ember.computed('model', function(){
    return this.get('model.ident');
  }),

  model: Ember.computed('task', 'ident', function() {
    let ident = this.get('ident');
    Ember.assert(`Expecting to be given an ident, but wasn't`, ident);

    let question = this.get('task').findQuestion(ident);
    if(question){
      return NestedQuestionProxy.create({nestedQuestion: question, owner: this.get('task')});
    } else {
      return null;
    }
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
