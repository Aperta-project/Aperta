import Ember from 'ember';
var NestedQuestionComponent;

NestedQuestionComponent = Ember.Component.extend({
  tagName: 'div',
  helpText: null,
  disabled: false,

  model: (function() {
    let ident = this.get('ident');
    let question = this.get('task').findQuestion(ident);

    Ember.assert(`Expecting to find question matching ident '${ident}' but didn't`, question);
    return question;
  }).property('task', 'ident'),

  additionalData: Ember.computed.alias('model.additionalData')
});

export default NestedQuestionComponent;
