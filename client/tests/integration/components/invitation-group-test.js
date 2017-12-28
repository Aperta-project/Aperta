import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import MockDataTransfer from 'tahi/tests/helpers/data-transfer';
import DragNDrop from 'tahi/services/drag-n-drop';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import { triggerEvent } from 'ember-native-dom-helpers';

moduleForComponent(
  'invitation-group',
  'Integration | Component | invitation group',
  {
    integration: true,
    afterEach() {
      DragNDrop.set('dragItem', null);
    },
    beforeEach() {
      manualSetup(this.container);
      let can = FakeCanService.create();
      let task = make('task');
      this.registry.register('service:can', can.allowPermission('manage_invitations', task).asService());
      this.makeInvitations = () => {
        return [
          make('invitation', {
            state: 'pending',
            position: 1,
            validNewPositionsForInvitation: [2]
          }),
          make('invitation', {
            state: 'pending',
            position: 2,
            validNewPositionsForInvitation: [1]
          })
        ];
      };
      this.makeThreeInvitations = () => {
        return [
          make('invitation', {
            state: 'pending',
            position: 1,
            validNewPositionsForInvitation: [2, 3]
          }),
          make('invitation', {
            state: 'pending',
            position: 2,
            validNewPositionsForInvitation: [1, 3]
          }),
          make('invitation', {
            state: 'pending',
            position: 3,
            validNewPositionsForInvitation: [1, 2]
          })
        ];
      };
    }
  }
);

let template = hbs`{{invitation-group
  owner=task
  invitations=invitations
  setRowState=(action noop)
  composedInvitation=null
  toggleActiveInvitation=(action noop)
  destroyInvite=(action noop)
  saveInvite=(action noop)
  previousRound=false
  activeInvitation=null
  activeInvitationState=null
}}`;

let noop = () => {};


test('it renders the invitations and drop targets', function(assert) {
  let invitations = this.makeInvitations();

  this.setProperties({ invitations, noop });
  this.render(template);
  assert.equal($('.invitation-item').length, 2);
  assert.equal($('.invitation-drop-target').length, 3);
});

test('dragging an invitation item', function(assert) {
  let invitations = this.makeInvitations();

  this.setProperties({ invitations, noop });
  this.render(template);

  let mockEvent = MockDataTransfer.makeMockEvent();

  let $invitation = $('.invitation-item').get(0);

  let $topTarget, $bottomTarget, $middleTarget;
  return triggerEvent($invitation, 'dragstart', mockEvent)
    .then(() => {
      assert.equal(DragNDrop.dragItem, invitations[0], 'the dragitem gets set');

      $topTarget = $('.invitation-drop-target').get(0);
      $bottomTarget = $('.invitation-drop-target')
        .last()
        .get(0);

      return triggerEvent($bottomTarget, 'dragenter', mockEvent);
    })
    .then(() => {
      assert.ok(
        $($bottomTarget).hasClass('current-drop-target'),
        'the bottom target is valid for the first invitation'
      );

      return triggerEvent($bottomTarget, 'dragleave');
    })
    .then(() => {
      assert.notOk(
        $($bottomTarget).hasClass('current-drop-target'),
        'the class gets removed on dragleave'
      );

      return triggerEvent($topTarget, 'dragenter');
    })
    .then(() => {
      assert.notOk(
        $($topTarget).hasClass('current-drop-target'),
        'the top target is not valid for the first invitation'
      );

      $middleTarget = $('.invitation-drop-target')
        .eq(1)
        .get(0);
      return triggerEvent($topTarget, 'dragleave');
    })
    .then(() => {
      return triggerEvent($middleTarget, 'dragenter');
    })
    .then(() => {
      assert.notOk(
        $($middleTarget).hasClass('current-drop-target'),
        'the middle target is not valid for the first invitation'
      );
    });
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

  let $invitation = $('.invitation-item')
    .eq(originalPosition - 1)
    .get(0);
  let $target = $('.invitation-drop-target')
    .eq(dropTargetIndex)
    .get(0);
  let mockEvent = MockDataTransfer.makeMockEvent();
  return triggerEvent($invitation, 'dragstart', mockEvent).then(() => {
    triggerEvent($target, 'drop', mockEvent);
  });
};

let assertChange = (assert, invitation, assertedPosition) => {
  invitation.changePosition = newPosition => {
    assert.equal(
      newPosition,
      assertedPosition,
      'the new position should be the position of the last item'
    );
  };
};

let failIfCalled = assert => {
  return () => {
    assert.ok(false, 'ChangePosition should not be called');
  };
};

test('dropping an invitation in a lower position', function(assert) {
  assert.expect(1);

  let invitations = this.makeThreeInvitations();

  assertChange(assert, invitations[0], 2);
  this.setProperties({ invitations, noop });
  this.render(template);

  return dropInvitation(1, 2);
});

test('dropping an invitation to the bottom position', function(assert) {
  assert.expect(1);

  let invitations = this.makeThreeInvitations();

  assertChange(assert, invitations[0], 3);
  this.setProperties({ invitations, noop });
  this.render(template);

  return dropInvitation(1, 3);

});

test('dropping an invitation in a higher position', function(assert) {
  assert.expect(1);

  let invitations = this.makeThreeInvitations();

  assertChange(assert, invitations[2], 2);
  this.setProperties({ invitations, noop });
  this.render(template);
  return dropInvitation(3, 1);
});

test('dropping an invitation in the top position', function(assert) {
  assert.expect(1);

  let invitations = this.makeThreeInvitations();
  assertChange(assert, invitations[2], 1);
  this.setProperties({ invitations, noop });
  this.render(template);
  return  dropInvitation(3, 0);
});

test('dropping an invitation on an adjacent target is a noop', function(
  assert
) {
  assert.expect(1);

  let invitations = this.makeThreeInvitations();
  failIfCalled(assert);

  this.setProperties({ invitations, noop });
  this.render(template);
  return dropInvitation(1, 0).then(() => {
    dropInvitation(1, 1);
  }).then(() => {
    assert.ok(true);
  });
});
