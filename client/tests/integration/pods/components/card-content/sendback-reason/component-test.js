import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';


moduleForComponent('card-content/sendback-reason', 'Integration | Component | card content/sendback reason', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.set('actionStub', function() {});
    this.set('answerActionStub', function() {});
    this.set('owner', make('custom-card-task'));
    this.set('content', Ember.Object.create({ ident: 'test' }));
    this.set('answer', Ember.Object.create({ value: null }));
    this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
  }
});

let createSendbackWithChildren = () => {
  let sendback = make('card-content', {
    contentType: 'sendback-reason'
  });
  make('card-content', {
    contentType: 'check-box',
    ident: 'reason',
    label: 'See me!',
    text: 'lalalala',
    valueType: 'boolean',
    parent: sendback
  });
  make('card-content', { // pencil
    contentType: 'check-box',
    valueType: 'boolean',
    parent: sendback
  });
  make('card-content', { // sendback reason textarea
    contentType: 'paragraph-input',
    ident: 'text-reason',
    parent: sendback
  });
  return sendback;
};

test('it shows its text if provided', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(hbs`{{card-content/sendback-reason 
  content=sendback 
  answer=answer 
  disabled=disabled 
  owner=owner 
  valueChanged=(action actionStub)}}`);

  assert.equal(this.$('.content-text').text().trim(), 'lalalala');
});

test('it shows its label if provided', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(hbs`{{card-content/sendback-reason 
  content=sendback 
  answer=answer 
  disabled=disabled 
  owner=owner 
  valueChanged=(action actionStub)}}`);

  assert.equal(this.$('label').first().text().trim(), 'See me!');
});


test('it displays the pencil if sendback reason is checked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(hbs`{{card-content/sendback-reason 
  content=sendback 
  answer=answer 
  disabled=disabled 
  owner=owner 
  valueChanged=(action actionStub)}}`);

  this.$('#check-box-reason').click();
  assert.elementFound('.fa-pencil');

});

test('it hides the pencil if sendback reason is unchecked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(hbs`{{card-content/sendback-reason 
  content=sendback 
  answer=answer 
  disabled=disabled 
  owner=owner 
  valueChanged=(action actionStub)}}`);

  assert.elementNotFound('.fa-pencil');

});

test('it displays the textrea if sendback reason is checked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(hbs`{{card-content/sendback-reason 
  content=sendback 
  answer=answer 
  disabled=disabled
  preview=true
  owner=owner 
  valueChanged=(action actionStub)}}`);

  this.$('#check-box-reason').click();

  this.$('.fa-pencil').click();
  assert.elementFound('.card-content-paragraph-input');
});

test('it hides the textrea if sendback reason is checked but the pencil has not been clicked', function(assert) {

  let sendback = createSendbackWithChildren();
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('sendback', sendback);

  this.render(hbs`{{card-content/sendback-reason 
  content=sendback 
  answer=answer 
  disabled=disabled
  preview=true
  owner=owner 
  valueChanged=(action actionStub)}}`);

  this.$('#check-box-reason').click();
  assert.elementNotFound('.card-content-paragraph-input');
});
