import { moduleForComponent, test} from 'ember-qunit';
import {make, manualSetup, mockCreate} from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('custom-card-task', 'Integration | Components | Card Content', {
  integration: true,

  beforeEach() {
    this.registry.register('service:pusher', Ember.Object.extend({socketId: 'foo'}));
    manualSetup(this.container);
    registerCustomAssertions();
    this.registry.register('service:can', FakeCanService);

    let task = make('custom-card-task');
    this.set('task', task);
    this.set('repetition', null);
    this.set('preview', false);
    mockCreate('answer');
  },

  afterEach() {
    $.mockjax.clear();
  }
});

test('it renders the custom card content starting in a non error state', function(assert) {
  // factory builds a CustomCardTask along with a piece of sample CardContent
  let task = make('custom-card-task', {notReady: false});
  this.set('task', task);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.render(hbs`
    {{custom-card-task task=task}}
  `);

  assert.elementFound('.card-content-short-input', 'found the associated card content');
  assert.elementFound('.task-completed.button--green', 'non error state button is green');
  assert.elementNotFound('.task-completed-section .error-message', 'non error state contains no error message');
});


test('if errors are present on submit, the complete button gets an error state', function(assert) {
  // factory builds a CustomCardTask along with a piece of sample CardContent
  let task = make('custom-card-task', {notReady: true});
  this.set('task', task);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.render(hbs`
    {{custom-card-task task=task}}
  `);

  assert.elementFound('.task-completed.button--green', 'error state button is green');
  assert.elementFound('.task-completed-section .error-message', 'error state contains error message');
});

test('it creates an answer for card-content', function(assert) {
  // add a single piece of answerable card content to work with
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=preview}}
  `);

  assert.expect(2);

  wait().then(() => {
    assert.elementsFound('input.card-input', 1);
    this.$('input.card-input').val('a new answer').trigger('input').blur();
  });

  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST');
  });
});

test('it does not create an answer for non answerables', function(assert) {

  // add a single piece of non-answerable card content to work with
  let cardContent = make('card-content', 'description');
  this.set('task.cardVersion.contentRoot', cardContent);

  assert.expect(1);

  this.render(hbs`
    {{custom-card-task task=task preview=preview}}
  `);

  return wait().then(() => {
    assert.equal(this.get('task.cardVersion.contentRoot.answers.length'), 0, 'there are no answers for a paragraph tag');
  });
});

test('it renders text for card-content', function(assert) {
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=preview}}
  `);

  assert.textPresent('.card-form-text', 'A short input question');
});

test('it renders a label for card-content', function(assert) {
  let cardContent = make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=preview}}
  `);

  return wait().then(() => {
    assert.elementFound('label.card-form-element');
  });
});

test('it displays an indicator for required fields', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: true, label: 'Label', text: 'Text', repetition: null });
  let root = 'task.cardVersion.contentRoot';
  let label = `${root}.label`;
  this.set(root, cardContent);

  let template = hbs`
    {{custom-card-task task=task preview=preview}}
  `;

  this.render(template);
  return wait().then(() => {
    assert.elementFound('.required-field', 'shows the required field indicator when the label is present');

    this.set(label, null);
    assert.elementNotFound('.required-field', 'shows no required field indicator when the label is absent');
  });
});

test('it does not display an indicator for non-required fields', function(assert) {
  let cardContent = make('card-content', 'shortInput', { requiredField: false });
  this.set('task.cardVersion.contentRoot', cardContent);

  this.set(
    'content',
    Ember.Object.create({
      ident: 'test',
      text: 'Test check-box',
      label: 'some label'
    })
  );

  this.render(hbs`
    {{custom-card-task task=task preview=preview}}
  `);

  return wait().then(() => {
    assert.elementNotFound('.required-field');
  });
});

test('When having "false" as the content.defaultAnswerValue it casts it to boolean', function(assert) {
  let cardContent = make('card-content', 'checkBox');
  this.set('content', cardContent);
  this.set('owner', Ember.Object.create());
  this.set('preview', true);

  this.render(hbs` {{card-content content=content owner=owner preview=preview repetition=repetition }}`);
  return wait().then(() => {
    assert.equal(this.$('input[type=checkbox]').is(':checked'), false);
  });
});

test('When having "true" as the content.defaultAnswerValue it casts it to boolean', function(assert) {
  let cardContent = make('card-content', 'checkBox');
  Ember.run(() => {
    cardContent.set('defaultAnswerValue', 'true');
  });
  this.set('content', cardContent);
  this.set('owner', Ember.Object.create());
  this.set('preview', true);

  this.render(hbs` {{card-content content=content owner=owner preview=preview repetition=repetition }}`);
  return wait().then(() => {
    assert.equal(this.$('input[type=checkbox]').is(':checked'), true);
  });
});
