import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import { mockCreate } from 'ember-data-factory-guy/factory-guy-test-helper';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';

moduleForComponent(
  'admin-page/new-card-overlay',
  'Integration | Component | Admin page | new card overlay',
  {
    integration: true,

    beforeEach() {
      manualSetup(this.container);
      registerCustomAssertions();
      this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
      this.set(
        'journal',
        make('admin-journal', { cardTaskTypes: [make('card-task-type')] })
      );
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

let template = hbs`{{admin-page/new-card-overlay
    journal=journal
    success=(action "success")
    close=(action "close")}}`;

test('it creates a record when the save button is pushed', function(assert) {
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  mockCreate('card');

  this.render(template);

  this.$('.admin-overlay-save').click();
  return wait().then(() => {
    assert.mockjaxRequestMade('/api/cards', 'POST');
    assert.spyCalled(success, 'Should call success callback');
    assert.spyCalled(close, 'Should call close');
  });
});

test('it does not create a record when the cancel button is pushed', function(
  assert
) {
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  mockCreate('card');

  this.render(template);

  this.$('.admin-overlay-cancel').click();

  return wait().then(() => {
    assert.mockjaxRequestNotMade('/api/cards', 'POST');
    assert.spyNotCalled(success, 'Should not call success callback');
    assert.spyCalled(close, 'Should call close');
  });
});
