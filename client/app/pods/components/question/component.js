import Ember from 'ember';
var QuestionComponent;

QuestionComponent = Ember.Component.extend({
  tagName: 'div',
  helpText: null,
  disabled: false,
  model: (function() {
    var ident, question;
    ident = this.get('ident');
    Ember.assert('You must specify an ident, set to name attr', ident);
    question = this.get('versioned') ? this.get('task.paper.latestDecision.questions').find((function(_this) {
      return function(item) {
        return item.get('task') === _this.get('task') && item.get('ident') === ident;
      };
    })(this)) : this.get('task.questions').findProperty('ident', ident);
    if (!question) {
      question = this.createNewQuestion();
    }
    return question;
  }).property('task', 'ident'),
  createNewQuestion: function() {
    var data, key, question, task, value;
    task = this.get('task');
    question = task.get('store').createRecord('question', {
      question: this.get('question'),
      ident: this.get('ident'),
      task: task,
      decision: task.get('paper.latestDecision'),
      additionalData: [{}]
    });
    data = {};
    key = this.get("additionalDataKey");
    value = this.get("additionalDataValue");
    if (key && value) {
      data[key] = value;
      question.set("additionalData", [data]);
    }
    task.get('questions').pushObject(question);
    return question;
  },
  additionalData: Ember.computed.alias('model.additionalData'),
  change: function() {
    Ember.run.debounce(this, this._saveModel, this.get('model'), 200);
    return false;
  },
  _saveModel: function(model) {
    return model.save();
  }
});

export default QuestionComponent;
