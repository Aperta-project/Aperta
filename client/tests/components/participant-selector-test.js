import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent('participant-selector', 'Integration | Component | participant selector', {
  integration: true,
  beforeEach() {
    customAssertions();
    this.testUser = Ember.Object.create({
      fullName: 'Bruce Wayne',
      avatarUrl: 'foo',
      email: 'batman@example.com'
    });

    this.setProperties({
      currentParticipants: [this.testUser]
    });

  }
});

test('it renders currentParticipants', function(assert) {
  this.render(hbs`{{participant-selector
    currentParticipants=currentParticipants
    url="url"
    displayEmails=false
    canManage=true}}`);

  let thumb = $('.participant-selector .user-thumbnail-small');
  assert.equal(thumb.attr('alt'), 'Bruce Wayne', 'alt is set to user\'s full name');
  assert.equal(thumb.attr('src'), 'foo', 'src is set to the avatarUrl');
  assert.equal(thumb.attr('data-toggle'), 'tooltip', 'data-toggle is set when canManage is true');
  assert.equal(thumb.attr('data-original-title'), 'Bruce Wayne', 'title is set and then modified by jquery plugin');

});

test('it renders currentParticipants emails when available', function(assert) {

  this.render(hbs`{{participant-selector
    currentParticipants=currentParticipants
    url="url"
    displayEmails=true
    canManage=true}}`);

  let thumb = $('.participant-selector .user-thumbnail-small');
  assert.equal(thumb.attr('data-original-title'), 'Bruce Wayne batman@example.com', 'renders name and email');

});

test('if email is blank it\'s not shown', function(assert) {

  this.testUser.set('email', null);
  this.render(hbs`{{participant-selector
    currentParticipants=currentParticipants
    url="url"
    displayEmails=true
    canManage=true}}`);

  let thumb = $('.participant-selector .user-thumbnail-small');
  assert.equal(thumb.attr('data-original-title'), 'Bruce Wayne', 'renders only name');

});

test('it doesn\'t add data-toggle when canManage is false', function(assert) {
  this.render(hbs`{{participant-selector
    currentParticipants=currentParticipants
    url="url"
    displayEmails=true
    canManage=false}}`);

  let thumb = $('.participant-selector .user-thumbnail-small');
  assert.equal(thumb.attr('data-toggle'), null, 'data-toggle is not set');
});
