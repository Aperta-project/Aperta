import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('overlay-task-header', 'Integration | Component | overlay task header', {
  integration: true,
  beforeEach() {
    this.set('animation', () => {});

    this.set('displayTask', Ember.Object.create({
      id: 'id-1',
      title: 'Adhoc Task',
      type: 'Task',
      paper: Ember.Object.create({
        id: 'id-2',
        index: 'papers',
        manuscript_id: 'test.10001',
        paperType: 'Research',
        publishingState: 'submitted',
        displayTitle: 'Chemistry is Amazing',
        creatorUser: Ember.Object.create({
          user: Ember.Object.create({
            full_name: 'Anna Author'
          })
        })
      })
    }));

    this.render(hbs`
      {{overlay-task-header task=displayTask animateOut=animation}}
    `);
  }
});

test("displays author name", function(assert) {
  assert.textPresent('li', 'Anna Author');
});

test("displays manuscript id", function(assert) {
  assert.textPresent('li', 'test.10001');
});

test("displays article type", function(assert) {
  assert.textPresent('li', 'Research');
});

test("displays manuscript status", function(assert) {
  assert.textPresent('li', 'Submitted');
});

test("displays paper title", function(assert) {
  assert.textPresent('span', 'Chemistry is Amazing');
});
