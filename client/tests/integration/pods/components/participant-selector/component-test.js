/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import customAssertions from 'tahi/tests/helpers/custom-assertions';
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
  this.set('currentParticipants', []);
  this.render(hbs`
   {{participant-selector currentParticipants=currentParticipants
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
