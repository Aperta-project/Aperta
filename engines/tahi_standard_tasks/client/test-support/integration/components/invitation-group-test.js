import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { make } from 'ember-data-factory-guy';
import MockDataTransfer from 'tahi/tests/helpers/data-transfer';
import startApp from 'tahi/tests/helpers/start-app';
import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

let App;
moduleForComponent('invitation-group', 'Integration | Component | invitation group', {
  integration: true,
  setup: function() {
    //since we're starting the full app we don't need to manually set up factoryguy
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

let template = hbs`{{invitation-group
  invitations=invitations
  setRowState=(action noop)
  composedInvitation=null
  toggleActiveInvitation=(action noop)
  destroyInvite=(action noop)
  saveInvite=(action noop)
  previousRound=false
  activeInvitation=null
  activeInvitationState=null
  changePosition=(action changePosition)
}}`;

let noop = () => {};

let changePosition = () => {};

let makeInvitations = () => {
  return [
    make(
      'invitation',
      {
        state: 'pending',
        position: 1,
        validNewPositionsForInvitation: [2]
      }),
    make(
      'invitation',
      {
        state: 'pending',
        position: 2,
        validNewPositionsForInvitation: [1]
      }),
  ];
};

test('it renders the invitations and drop targets', function(assert) {
  let invitations = makeInvitations();

  this.setProperties({invitations, noop, changePosition});
  this.render(template);

  assert.equal($('.invitation-item').length, 2);
  assert.equal($('.invitation-drop-target').length, 3);
});

test('dragging an invitation item', function(assert) {
  let invitations = makeInvitations();

  this.setProperties({invitations, noop, changePosition});
  this.render(template);

  let mockEvent = MockDataTransfer.makeMockEvent();

  let $invitation = $('.invitation-item').first();

  Ember.run(() => {
    triggerEvent($invitation, 'dragstart', mockEvent);
  });

  assert.equal(DragNDrop.dragItem, invitations[0], 'the dragitem gets set');

  let $topTarget = $('.invitation-drop-target').first();
  let $bottomTarget = $('.invitation-drop-target').last();

  Ember.run(() => {
    triggerEvent($bottomTarget, 'dragenter', mockEvent);
  });

  assert.ok(
    $bottomTarget.hasClass('current-drop-target'),
    'the bottom target is valid for the first invitation'
  );
  Ember.run(() => {
    triggerEvent($bottomTarget, 'dragleave');
  });
  assert.notOk(
    $bottomTarget.hasClass('current-drop-target'),
    'the class gets removed on dragleave'
  );

  Ember.run(() => {
    triggerEvent($topTarget, 'dragenter');
  });
  assert.notOk(
    $topTarget.hasClass('current-drop-target'),
    'the top target is not valid for the first invitation'
  );

  let $middleTarget = $('.invitation-drop-target').eq(1);
  Ember.run(() => {
    triggerEvent($topTarget, 'dragleave');
    triggerEvent($middleTarget, 'dragenter');
  });
  assert.notOk(
    $middleTarget.hasClass('current-drop-target'),
    'the middle target is not valid for the first invitation'
  );
});

let dropInvitation = (originalPosition, dropTargetIndex) => {
  /*  here's an example of how drop target and invitations are arrayed
* targets are 0-indexed, invitations are 1-index (same as position)
* target[0]
* invitation 1 (position 1)
* target[1]
* invitation 2  (position 2)
* target[2]
* invitation 3  (position 3)
* target[3]
*
* Invitations are interleaved through drop zones
*/

  let $invitation = $('.invitation-item').eq(originalPosition - 1);
  let $target = $('.invitation-drop-target').eq(dropTargetIndex);
  let mockEvent = MockDataTransfer.makeMockEvent();
  Ember.run(() => {
    triggerEvent($invitation, 'dragstart', mockEvent);
    triggerEvent($invitation, 'dragend', mockEvent);

    triggerEvent($target, 'dragend', mockEvent);
    triggerEvent($target, 'drop', mockEvent);
  });
};

let assertChange = (assert, invitation, assertedPosition) => {
  return (newPosition, item) => {
    assert.equal(item, invitation, 'sends changePosition with the dropped invitation');
    assert.equal(newPosition, assertedPosition, 'the new position should be the position of the last item');
  };
};

let failIfCalled = (assert) => {
  return () => {
    assert.ok(false, 'ChangePosition should not be called');
  };
};

let makeThreeInvitations = () => {
  return [
    make(
      'invitation',
      {
        state: 'pending',
        position: 1,
        validNewPositionsForInvitation: [2, 3]
      }),
    make(
      'invitation',
      {
        state: 'pending',
        position: 2,
        validNewPositionsForInvitation: [1, 3]
      }),
    make(
      'invitation',
      {
        state: 'pending',
        position: 3,
        validNewPositionsForInvitation: [1, 2]
      }),
  ];
};

test('dropping an invitation in a lower position', function(assert) {
  assert.expect(2);

  let invitations = makeThreeInvitations();
  let changePosition = assertChange(assert, invitations[0], 2);

  this.setProperties({invitations, noop, changePosition});
  this.render(template);

  dropInvitation(1, 2);
});

test('dropping an invitation to the bottom position', function(assert) {
  assert.expect(2);

  let invitations = makeThreeInvitations();
  let changePosition = assertChange(assert, invitations[0], 3);

  this.setProperties({invitations, noop, changePosition});
  this.render(template);

  dropInvitation(1, 3);
});

test('dropping an invitation in a higher position', function(assert) {
  assert.expect(2);

  let invitations = makeThreeInvitations();
  let changePosition = assertChange(assert, invitations[2], 2);

  this.setProperties({invitations, noop, changePosition});
  this.render(template);
  dropInvitation(3, 1);

});

test('dropping an invitation in the top position', function(assert) {
  assert.expect(2);

  let invitations = makeThreeInvitations();
  let changePosition = assertChange(assert, invitations[2], 1);

  this.setProperties({invitations, noop, changePosition});
  this.render(template);
  dropInvitation(3, 0);

});

test('dropping an invitation on an adjacent target is a noop', function(assert) {
  assert.expect(1);

  let invitations = makeThreeInvitations();
  let changePosition = failIfCalled(assert);

  this.setProperties({invitations, noop, changePosition});
  this.render(template);
  dropInvitation(1, 0);
  dropInvitation(1, 1);
  assert.ok(true);
});
