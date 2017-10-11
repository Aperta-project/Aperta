import {
  moduleForComponent,
  moduleFor,
  test
} from 'ember-qunit';

import customAssertions from '../helpers/custom-assertions';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import wait from 'ember-test-helpers/wait';

moduleForComponent('participant-selector', 'Integration | Component | participant selector', {
  integration: true,
  beforeEach() {
    customAssertions();
    this.testUser = Ember.Object.create({
      email: 'batman@example.com',
      fullName: 'Bruce Wayne',
      id: 1
    });

    this.setProperties({
      currentParticipants: [this.testUser],
      searchingParticipant: false,
      canRemoveSingleUser: false,
      canManage: true,
      onRemove() {},
      onSelect() {},
      searchStarted() {},
      searchFinished() {}
    });
  },

  afterEach() {
    $.mockjax.clear();
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
  assert.equal(name.text(), 'Bruce Wayne', 'full name is displayed');
});

test('remove link', function(assert) {
  this.get('currentParticipants').pushObject(Ember.Object.create({
    fullName: 'Barbara Gordon',
    email: 'barbara@example.com'
  }));

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

  let thumb  = $('.participant-selector-user:first');
  let remove = thumb.find('.participant-selector-user-remove');
  assert.ok(remove.length, 'remove is available when canManage is true and there are more than one participants');

  this.set('canManage', false);
  thumb  = $('.participant-selector-user:first');
  remove = thumb.find('.participant-selector-user-remove');
  assert.ok(!remove.length, 'remove is not available when canManage is false and there are more than one participants');

  this.setProperties({
    canManage: true,
    currentParticipants: [this.testUser]
  });
  thumb  = $('.participant-selector-user:first');
  remove = thumb.find('.participant-selector-user-remove');
  assert.ok(!remove.length, 'remove is not available when canManage is true and there is one participant');
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

function withUserSuggestions(users, assert, ctx, callback) {
  ctx.fakeURL = '/people';
  ctx.searchStarted = () => { ctx.set('searchingParticipant', true); };
  ctx.render(hbs`
    {{participant-selector currentParticipants=currentParticipants
                           url=fakeURL
                           displayEmails=true
                           searching=searchingParticipant
                           onRemove=onRemove
                           onSelect=onSelect
                           searchStarted=searchStarted
                           searchFinished=searchFinished
                           canManage=canManage}}
  `);
  $.mockjax({
    url: `${ctx.fakeURL}?query=meow`,
    status: 200,
    responseText: { users }
  });
  ctx.$('.add-participant-button').click();
  $('.ember-power-select-search-input').val('meow');
  $('.ember-power-select-search-input').trigger('input');
  const start = assert.async();
  wait().then(function() {
    callback.call();
    start();
  });
}

test('it shows suggestions', function(assert) {
  const user = {
    id: '2',
    full_name: 'Pikachu Pokémon',
    username: 'pikachu',
    email: 'pikachu@oak.edu'
  };
  withUserSuggestions([user], assert, this, function() {
    assert.elementFound($('.ember-power-select-option').length);
    assert.textPresent('.ember-power-select-option .suggestion-sub-value', 'pikachu@oak.edu');
  });
});

test('it does not suggest people who are already participants', function(assert) {
  const user = {
    id: '1',
    full_name: 'Pikachu Pokémon',
    username: 'pikachu',
    email: 'pikachu@oak.edu'
  };
  withUserSuggestions([user], assert, this, function() {
    assert.textPresent('.ember-power-select-option', 'No results found');
  });
});


test('renders remove link if canRemoveSingleUser is set to true and there is one participant', function(assert) {
  this.render(hbs`
   {{participant-selector currentParticipants=currentParticipants
                          url="url"
                          displayEmails=false
                          searching=searchingParticipant
                          onRemove=onRemove
                          onSelect=onSelect
                          searchStarted=searchStarted
                          searchFinished=searchFinished
                          canRemoveSingleUser=true
                          canManage=canManage}}
 `);

  let thumb  = $('.participant-selector-user:first');
  let remove = thumb.find('.participant-selector-user-remove');
  assert.ok(remove.length, 'remove is available when canRemoveSingleUser is true');
});

test('remove link is not rendered if canRemoveSingleUser is set to false', function(assert) {
  this.render(hbs`
   {{participant-selector currentParticipants=currentParticipants
                          url="url"
                          displayEmails=false
                          searching=searchingParticipant
                          onRemove=onRemove
                          onSelect=onSelect
                          searchStarted=searchStarted
                          canRemoveSingleUser=false
                          searchFinished=searchFinished
                          canManage=canManage}}
 `);

  let thumb  = $('.participant-selector-user:first');
  let remove = thumb.find('.participant-selector-user-remove');
  assert.ok(!remove.length, 'remove is not available when canRemoveSingleUser is false even if there is an assigned user');
});

test('remove link is not rendered if there are not currentParticipants but canRemoveSingleUser is true', function(assert) {
  this.render(hbs`
   {{participant-selector currentParticipants=[]
                          url="url"
                          displayEmails=false
                          searching=searchingParticipant
                          onRemove=onRemove
                          onSelect=onSelect
                          searchStarted=searchStarted
                          canRemoveSingleUser=true
                          searchFinished=searchFinished
                          canManage=canManage}}
 `);

  let thumb  = $('.participant-selector-user:first');
  let remove = thumb.find('.participant-selector-user-remove');
  assert.ok(!remove.length, 'remove is not available because there are not participants');
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
