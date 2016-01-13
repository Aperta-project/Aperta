import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';

const { isEmpty } = Ember;
const { RSVP } = Ember;

const restlessMock = Ember.Object.create({
  get() {
    return RSVP.resolve({});
  },
  'delete': function() {
    return RSVP.resolve({});
  }
});

/*
  Fake data is four objects.
  Three of them DiscussionTopics, one DiscussionReply.
  All of them belong to the same paper except for one DiscussionTopic, dt3.
*/

const dt1 = {
  'id': 1,
  'paper_id': 11,
  'user_id': 1,
  'target_id': 1,
  'target_type': 'DiscussionTopic',
  'parent_id': '',
  'parent_type': ''
};

const dt2 = {
  'id': 2,
  'paper_id': 11,
  'user_id': 1,
  'target_id': 2,
  'target_type': 'DiscussionTopic',
  'parent_id': '',
  'parent_type': ''
};

const dt3 = {
  'id': 3,
  'paper_id': 12,
  'user_id': 1,
  'target_id': 3,
  'target_type': 'DiscussionTopic',
  'parent_id': '',
  'parent_type': ''
};

const dr1 = {
  'id': 4,
  'paper_id': 11,
  'user_id': 1,
  'target_id': 1,
  'target_type': 'DiscussionReply',
  'parent_id': 1,
  'parent_type': 'DiscussionTopic'
};


moduleFor('service:notifications', 'NotificationsService');

test('#peekNotifications', function(assert) {
  let notifications;
  const service = this.subject({
    _data: [dt1, dt2, dt3, dr1],
    restless: restlessMock
  });

  assert.equal(
    service.get('_data.length'), 4,
    'Data loaded'
  );

  // no params
  notifications = service.peekNotifications();
  assert.equal(notifications.length, 4, 'Find all');

  // type & id
  notifications = service.peekNotifications('DiscussionTopic', 3);
  assert.equal(notifications[0].paper_id, 12, 'Find correct topic');

  // type & id
  notifications = service.peekNotifications('DiscussionReply', 1);
  assert.equal(notifications[0].paper_id, 11, 'Find correct reply');

  // paper
  notifications = service.peekNotifications('paper', 11);
  assert.equal(notifications.length, 3, 'Finds all for paper');
});


test('#peekParentNotifications', function(assert) {
  let notifications;
  const service = this.subject({
    _data: [dt1, dt2, dt3, dr1],
    restless: restlessMock
  });

  assert.equal(
    service.get('_data.length'), 4,
    'Data loaded'
  );

  notifications = service.peekNotifications('DiscussionTopic', 2);
  assert.equal(notifications[0].paper_id, 11, 'Find correct topic');
});


test('#count', function(assert) {
  let count;
  const service = this.subject({
    _data: [dt1, dt2, dt3, dr1],
    restless: restlessMock
  });

  assert.equal(
    service.get('_data.length'), 4,
    'Data loaded'
  );

  // no params
  count = service.count();
  assert.equal(count, 4, 'Find all');

  count = service.count('DiscussionTopic', 1, true);
  assert.equal(count, 2, 'DiscussionTopic and child');
});

test('#removeNotificationsFromStoreById', function(assert) {
  let count;
  let notifications;
  const service = this.subject({
    _data: [dt1, dt2, dt3, dr1],
    restless: restlessMock
  });

  assert.equal(
    service.get('_data.length'), 4,
    'Data loaded'
  );

  service.removeNotificationsFromStoreById([1,2]);
  count = service.count();
  notifications = service.peekNotifications();

  assert.equal(count, 2, 'Notifications removed');
  assert.equal(notifications[0].id, 3, 'Correct notifications removed');
  assert.equal(notifications[1].id, 4, 'Correct notifications removed');
});
