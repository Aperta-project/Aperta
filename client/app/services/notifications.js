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
    this.get('restless')
        .delete('/api/notifications/destroy?ids=' + ids.toString()).then(()=> {
          this.removeNotificationsById(ids);
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

    // Return all for a type
    if(notEmpty(type) && isEmpty(id)) {
      return data.filterBy('target_type', type);
    }

    return data.filter(n => {
      return parseInt(n.target_id) === parseInt(id) && n.target_type === type;
    });
  },

  peekParentNotifications(type, id) {
    return this.get('_data').filter(n => {
      return parseInt(n.parent_id) === parseInt(id) && n.parent_type === type;
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
    this.removeNotificationsById([payload.id]);
  },

  removeNotificationsById(ids) {
    this.get('_data')
        .removeObjects(this.get('_data').map(function(n) {
          if(ids.contains(n.id)) {
            return n;
          }
        }));
  }
});
