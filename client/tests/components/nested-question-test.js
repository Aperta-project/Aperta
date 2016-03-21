import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';

moduleForComponent('nested-question', 'Component: nested-question', {
  unit: true,

  beforeEach: function() {
    this.q1 = Ember.Object.create({
      ident: "foo",
      answerForOwner: function(){ }
    });
    return this.q2 = Ember.Object.create({
      ident: "bar",
      answerForOwner: function(){ }
    });
  }
});

test('#model: can be set when finding the question for given ident', function(assert) {
  let task = Ember.Object.create({
    findQuestion: () => { return this.q1; }
  });
  let component = this.subject({
    owner: task,
    ident: "foo"
  });
  assert.equal(component.get('model.ident'), this.q1.get('ident'), 'Finds its model by ident');
  assert.equal(component.get('ident'), this.q1.get('ident'), 'ident is set based on the given ident');
});

test('#model: can be set when supplied directly with no ident', function(assert) {
  let task = Ember.Object.create({
    findQuestion: () => { return this.q1; }
  });
  let component = this.subject({
    owner: task,
    model: this.q1
  });
  assert.equal(component.get('model.ident'), this.q1.get('ident'), 'Model is set directly');
  assert.equal(component.get('ident'), this.q1.get('ident'), 'ident is set based on the model');
});

test('#questionText: is the text of the model', function(assert) {
  this.q1.set('text', "How's it going?");
  let task = Ember.Object.create({
    findQuestion: () => { return this.q1; }
  });
  let component = this.subject({
    owner: task,
    model: this.q1
  });
  assert.equal(component.get('questionText'), "How's it going?", 'Model is set directly');
});

test('#shouldDisplayQuestionText: is true when there is a model and displayQuestionText is true', function(assert){
  let task = Ember.Object.create({
    findQuestion: () => { return this.q1; }
  });
  let component = this.subject({
    owner: task,
    model: this.q1,
    displayQuestionText: true
  });
  assert.equal(component.get('shouldDisplayQuestionText'), true, 'shouldDisplayQuestionText is true');
});

test('#shouldDisplayQuestionText: is false when there is a model and displayQuestionText is false', function(assert){
  this.q1.set('text', "How's it going?");
  let task = Ember.Object.create({
    findQuestion: () => { return this.q1; }
  });
  let component = this.subject({
    owner: task,
    model: this.q1,
    displayQuestionText: false
  });
  assert.equal(component.get('shouldDisplayQuestionText'), false, 'shouldDisplayQuestionText is false');
});
