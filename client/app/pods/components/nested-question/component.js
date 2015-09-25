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

  init: function(){
    this._super.apply(this, arguments);

    let ident = this.get('ident');
    let model = this.get('model');
    let task = this.get('task');

    Ember.assert("Must supply a task", task);

    if(!model){
      model = this.get('task').findQuestion(ident);
      Ember.assert(`Wasn't given a model. Expected to find one through
        findQuestion(${ident}), but didn't. Are you sure questions are loaded?`,
        model
      );
    }

    // Ensure that every model is a proxy for the owner so it cannot
    // lookup answers for the current owner.
    this.set('model', NestedQuestionProxy.create({
      nestedQuestion: model,
      owner: task
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
