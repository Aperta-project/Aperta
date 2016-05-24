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

test('basic paper information is included in overlay header', function(assert) {
  assert.textPresent('li', 'Anna Author', 'displays author name');
  assert.textPresent('li', 'test.10001', 'displays manuscript id');
  assert.textPresent('li', 'Research', 'displays article type');
  assert.textPresent('li', 'Submitted', 'displays manuscript status');
  assert.textPresent('span', 'Chemistry is Amazing', 'displays paper title');
});
