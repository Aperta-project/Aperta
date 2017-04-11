import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('custom-card-task', 'Integration | Components | Card Content', {
  integration: true,

  beforeEach() {
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    let task = FactoryGuy.make('custom-card-task');
    this.set('task', task);
  }
});

test('it creates an answer for card-content', function(assert) {

  // add a single piece of answerable card content to work with
  let cardContent = FactoryGuy.make('card-content', 'shortInput');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  $.mockjax({url: '/api/answers', type: 'POST', status: 201, responseText: '{}'});

  assert.elementsFound('input.form-control', 1);
  this.$('input.form-control').val('a new answer').trigger('input');

  let done = assert.async();
  wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST');
    $.mockjax.clear();
    done();
  });
});

test('it does not create an answer for non answerables', function(assert) {

  // add a single piece of non-answerable card content to work with
  let cardContent = FactoryGuy.make('card-content', 'text');
  this.set('task.cardVersion.contentRoot', cardContent);

  this.render(hbs`
    {{custom-card-task task=task preview=false}}
  `);

  assert.equal(this.get('task.cardVersion.contentRoot.answers.length'), 0, 'there are no answers for a paragraph tag');
});
