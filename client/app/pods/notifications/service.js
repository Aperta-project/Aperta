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

import Ember from 'ember';

const { isEmpty } = Ember;
const notEmpty = function(prop) {
  return !isEmpty(prop);
};

export default Ember.Service.extend(Ember.Evented, {
  restless: Ember.inject.service(),

  init() {
    this._super(...arguments);

    this._fetchData().then(response => {
      if(isEmpty(response) || isEmpty(response.notifications)) { return; }
      this.set('_data', response.notifications);
    });
  },

  /**
   *  Store for notifications
   *
   *  @property _data
   *  @type Array
   *  @default []
   *  @private
  **/

  _data: [],

  /**
   *  Get all unread notifications. Meant to be called from #init.
   *
   *  @method _fetchData
   *  @private
  **/

  _fetchData() {
    return this.get('restless').get('/api/notifications/');
  },

  /**
   *  Remove one or more notifcations. Sending `isParent` as true will also
   *  include Notifications that have the same parent object
   *
   *  @method remove
   *  @param {Object} options with type, id and isParent keys
   *  @public
  **/

  remove(options) {
    const { type, id } = options;
    const isParent = isEmpty(options.isParent) ? false : options.isParent;

    let parentIds = [];

    const ids = this.peekNotifications(type, id).map(function(n) {
      return n.id;
    });

    if(isParent) {
      parentIds = this.peekParentNotifications(type, id).map(function(n) {
        return n.id;
      });
    }

    this._persistRemoval(_.union(ids, parentIds));
  },

  /**
   *  Mark notifications as read on server
   *
   *  @method _persistRemoval
   *  @param {Array} ids array of notification ids
   *  @private
  **/

  _persistRemoval(ids) {
    if(isEmpty(ids)) { return; }

    this.get('restless')
        .delete('/api/notifications/destroy?ids=' + ids.toString()).then(()=> {
          this.removeNotificationsFromStoreById(ids);
        });
  },

  /**
   *  Get notifications in local store
   *
   *  @method peekNotifications
   *  @param {Object} options with type and id keys
   *  @public
  **/

  peekNotifications(type, id) {
    const data = this.get('_data');

    // No params, return all notifications
    if(isEmpty(type) && isEmpty(id)) { return data; }

    // Return all for a specific paper
    if(type === 'paper' && notEmpty(id)) {
      return data.filterBy('paper_id', parseInt(id));
    }

    return this.peekByKeys(data, 'target_type', type, 'target_id', id);
  },

  peekParentNotifications(type, id) {
    return this.peekByKeys(
      this.get('_data'),
      'parent_type', type,
      'parent_id', id
    );
  },

  peekByKeys(data, typeKey, type, idKey, id) {
    return data.filter(n => {
      return parseInt(n[idKey]) === parseInt(id) && n[typeKey] === type;
    });
  },

  /**
   *  Get count of notifications. Sending `isParent` as true will also
   *  include Notifications that have the same parent object
   *
   *  @method count
   *  @param {Object} options with type, id and isParent keys
   *  @public
  **/

  count(type, id, isParent=false) {
    if(type === 'DiscussionTopic' && isParent) {
      const topics = this.peekNotifications(type, id).get('length');
      const children = this.peekParentNotifications(type, id).get('length');

      return topics + children;
    }

    return this.peekNotifications(type, id).get('length');
  },

  /**
   *  Method called after Pusher update. Only an ID is provided,
   *  this method fetches the payload from the server
   *
   *  @method created
   *  @param {Object} payload with type and id keys
   *  @private
  **/

  created(payload) {
    this.get('restless').get('/api/notifications/' + payload.id).then(data => {
      this.get('_data').pushObject(data.notification);
    });
  },

  /**
   *  Method called after Pusher update.
   *
   *  @method destroyed
   *  @param {Object} payload with type and id keys
   *  @private
  **/

  destroyed(payload) {
    this.removeNotificationsFromStoreById([payload.id]);
  },

  /**
   *  Get count of notifications. Sending `isParent` as true will also
   *
   *  @method removeNotificationsFromStoreById
   *  @param {Array} ids
   *  @private
  **/

  removeNotificationsFromStoreById(ids) {
    this.get('_data')
        .removeObjects(this.get('_data').map(function(n) {
          if(ids.includes(n.id)) {
            return n;
          }
        }));
  }
});
