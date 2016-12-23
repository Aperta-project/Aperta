import {
  moduleForComponent,
  moduleFor,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent('participant-selector', 'Integration | Component | participant selector', {
  integration: true,
  beforeEach() {
    customAssertions();
    this.testUser = {
      fullName: 'Bruce Wayne',
      email: 'batman@example.com'
    };

    this.setProperties({
      currentParticipants: [this.testUser],
      searchingParticipant: false,
      canManage: true,
      actions: {
        onRemove() {},
        onSelect() {},
        searchStarted() {},
        searchFinished() {}
      }
    });
  }
});

test('it renders currentParticipants', function(assert) {
  this.render(hbs`
    {{participant-selector currentParticipants=currentParticipants
                           url="url"
                           displayEmails=false
                           searching=searchingParticipant
                           onRemove=onRemove
                           onSelect=onSelect
                           searchStarted=searchStarted
                           searchFinished=searchFinished
                           canManage=canManage}}
  `);

  const thumb  = $('.participant-selector-user');
  const name   = thumb.find('.participant-selector-user-name');
  const remove = thumb.find('.participant-selector-user-remove');
  assert.equal(name.text(), 'Bruce Wayne', 'full name is displayed');
  assert.ok(remove.length,  'remove is available when canManage is true');
});

test('it renders currentParticipants emails when available', function(assert) {
  this.render(hbs`
    {{participant-selector currentParticipants=currentParticipants
                           url="url"
                           displayEmails=true
                           searching=searchingParticipant
                           onRemove=onRemove
                           onSelect=onSelect
                           searchStarted=searchStarted
                           searchFinished=searchFinished
                           canManage=canManage}}
  `);

  const tooltip = $('.participant-selector-user .tooltip-inner');
  assert.ok(tooltip.text().match('batman@example.com'), 'renders email');
});

test('it does not display remove link when canManage is false', function(assert) {
  this.set('canManage', false);
  this.render(hbs`
    {{participant-selector currentParticipants=currentParticipants
                           url="url"
                           displayEmails=true
                           searching=searchingParticipant
                           onRemove=onRemove
                           onSelect=onSelect
                           searchStarted=searchStarted
                           searchFinished=searchFinished
                           canManage=canManage}}
  `);

  const remove = $('.participant-selector-user-remove');
  assert.ok(!remove.length, 'remove is not available when canManage is false');
});


moduleFor('component:participant-selector', 'Unit | Component | participant selector');

test('participantUrl defaults to the filtered users endpoint for the given paperId', function(assert) {
  assert.equal(
    this.subject({paperId: 10}).get('participantUrl'),
    '/api/filtered_users/users/10'
  );
});

test('participantUrl can be overwritten by passing in url', function(assert) {
  assert.equal(
    this.subject({url: 'foo'}).get('participantUrl'),
    'foo'
  );
});
