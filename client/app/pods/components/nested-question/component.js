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

    return NestedQuestionProxy.create({nestedQuestion: question, owner: this.get('task')});
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
    answer.save();
  }
});

export default NestedQuestionComponent;
