import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App = null;

moduleForComponent('card-preview', 'Unit: components/card-preview', {
  needs: ['helper:badge-count'],

  beforeEach: function() {
    Ember.run(function() {
      App = startApp();
      TestHelper.setup();
    });
  },

  afterEach: function() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, 'destroy');
  }
});

test('#unreadCommentsCount returns unread comments count', function(assert) {
  let task      = FactoryGuy.make('task', 'withUnreadComments');
  let component = this.subject({
    task: task
  });

  assert.equal(component.get('unreadCommentsCount'), 2);
});

test('#unreadCommentsCount gets updated when commentLook is "read"', function(assert) {
  let task      = FactoryGuy.make('task', 'withUnreadComments');
  let component = this.subject({
    task: task
  });

  Ember.run(function() {
    task.get('commentLooks').removeAt(0, 2);
    assert.equal(component.get('unreadCommentsCount'), 0);
  });
});
