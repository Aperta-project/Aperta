import Ember from 'ember';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  tagName: 'div',
  helpText: null,
  disabled: false,
  questionTextClass: "question-text",

  model: (function() {
    let ident = this.get('ident');
    Ember.assert(`Expecting to be given an ident, but wasn't`, ident);

    let question = this.get('task').findQuestion(ident);

    Ember.assert(`Expecting to find question matching ident '${ident}' but didn't`, question);
    return question;
  }).property('task', 'ident'),

  answerModel: Ember.computed('model', function(){
    return this.get('targetObject.store').createRecord('nested-question-answer', {
      nestedQuestion: this.get('model'),
      task: this.get('task'),
      value: this.get('model.value')
    });
  }),

  additionalData: Ember.computed.alias('model.additionalData'),

  change: function(){
    Ember.run.debounce(this, this._saveAnswer, this.get('answerModel'), 200);
    return false;
  },

  _saveAnswer: function(answerModel){
    answerModel.save();
  }
});

export default NestedQuestionComponent;
