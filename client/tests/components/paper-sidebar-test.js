import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from '../helpers/fake-can-service';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent('paper-sidebar', 'Integration | Component | paper sidebar', {
  integration: true,

  beforeEach() {
    initTruthHelpers();
    customAssertions();
  }
});

test('Shows the submit button when the paper is ready to submit and the user is authorized to submit', function(assert) {
  let paper = Ember.Object.create({isReadyForSubmission: true});
  this.set('paper', paper);

  this.registry.register('service:can', FakeCanService);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('submit', paper);

  let template = hbs`{{paper-sidebar paper=paper}}`;
  this.render(template);
  assert.elementFound(
    '#sidebar-submit-paper',
    'the submit button should be visible when the user is authorized'
  );

  fake.rejectPermission('submit');
  this.$().empty(); // this.render() only appends to the test container
  this.render(template);
  assert.elementNotFound(
    '#sidebar-submit-paper',
    'the submit button should NOT be visible when the user is unauthorized'
  );

});

const createTask = function (opts={}) {
  return Ember.Object.create(Ember.merge({
    isSidebarTask: true
  }, opts));
};

test('rendering a list of tasks', function(assert) {
  assert.expect(6);

  const paper =  Ember.Object.create({
    tasks: [
      createTask({ type: 'bulbasaur', position: 5, phase: { position: 5 } }),
      createTask({ type: 'charmander', position: 13, phase: { position: 1 } }),
      createTask({ type: 'bulbasaur', position: 3, phase: { position: 4 } }),
      createTask({ type: 'charmander', position: 2, phase: { position: 1 } }),
      createTask({ type: 'charmander', position: 1, phase: { position: 1 } })
    ]
  });
  this.set('paper', paper);

  this.registry.register('service:can', FakeCanService);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('submit', paper);

  this.render(hbs`{{paper-sidebar paper=paper}}`);

  assert.equal(this.$('.task-disclosure').length, 5);

  assert.ok(this.$('.task-disclosure').eq(0).hasClass(`task-type-charmander`));
  assert.ok(this.$('.task-disclosure').eq(1).hasClass(`task-type-charmander`));
  assert.ok(this.$('.task-disclosure').eq(2).hasClass(`task-type-charmander`));
  assert.ok(this.$('.task-disclosure').eq(3).hasClass(`task-type-bulbasaur`));
  assert.ok(this.$('.task-disclosure').eq(4).hasClass(`task-type-bulbasaur`));
});
