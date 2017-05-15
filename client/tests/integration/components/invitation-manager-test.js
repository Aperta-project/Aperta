import hbs from 'htmlbars-inline-precompile';
import page from 'tahi/tests/pages/invitation-manager';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import { manualSetup, make } from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('invitation-manager', 'Integration | Component | invitation manager', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    page.setContext(this);
    this.task = make('paper-reviewer-task', 'withInvitations');
    this.render(hbs`{{invitation-manager task=task}}`);
  },
  afterEach() {
    page.removeContext();
  }
});

test('it renders invitations', function(assert) {
  assert.expect(2);
  const invitationCount = this.task.get('invitations.length');
  assert.ok(invitationCount > 0, 'there should be some invitations on the task');
  assert.equal(page.invitations().count, invitationCount, 'theres should be some rendered invitations');
});

test('clicking an invitation expands that invitation', function(assert) {
  assert.expect(3);
  const firstInvitation = page.invitations(0);
  assert.notOk(firstInvitation.isExpanded, 'the invitation should not be expanded');
  firstInvitation.toggleExpand();
  assert.ok(firstInvitation.isExpanded, 'the invitation should be expanded');
  firstInvitation.toggleExpand();
  assert.notOk(firstInvitation.isExpanded, 'the invitation should not be expanded');
});

test('No invitation are draggable when one is expanded', function(assert) {
  assert.expect(3);
  const firstInvitation = page.invitations(0);
  assert.ok(page.allInvitationsDraggable(), 'all invitations should be draggable');
  firstInvitation.toggleExpand();
  assert.ok(page.noInvitationsDraggable(), 'no invitations should be draggable');
  firstInvitation.toggleExpand();
  assert.ok(page.allInvitationsDraggable(), 'all invitations should be draggable');
});

