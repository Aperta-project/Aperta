import Ember from 'ember';
import EmberPusher from 'ember-pusher';

const { isEmpty } = Ember;
const notEmpty = function(prop) {
  return !isEmpty(prop);
};

export default Ember.Service.extend(Ember.Evented, EmberPusher.Bindings, {
  restless: Ember.inject.service(),

  init() {
    this._super(...arguments);

    this._pusherSetup();

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
   *  Wire up pusher to listen for new notifications
   *
   *  @method _pusherSetup
   *  @private
  **/

  _pusherSetup() {
    this.get('pusher').wire(this,
      'private-user@' + this.get('currentUser.id'),
      ['created', 'destroyed']
    );
  },

  /**
   *  Remove one or more notifcations
   *
   *  @method remove
   *  @param {Object} options with type and id keys
   *  @public
  **/

  remove(options) {
    const { type, id } = options;

    // TEMPORARY:
    this.get('_data').removeObjects(this.peekNotifications(type, id));

    // const ids = this.peekNotifications(type, id).map(function(n) {
    //   return n.id;
    // });

    // this._persistRemoval(ids);
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
        .get('/api/notifications/destroy?ids=[' + ids.toString() + ']');
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

  /**
   *  Get count of notifications
   *
   *  @method count
   *  @param {Object} options with type and id keys
   *  @public
  **/

  count(type, id) {
    if(type === 'DiscussionTopic') {
      const topicCount = this.peekNotifications(type, id);
      return topicCount.get('length');
    }

    return this.peekNotifications(type, id).get('length');
  },

  actions: {
    created(payload) {
      console.log(payload.type);
    },

    destroyed(payload) {
      console.log(payload.type);
    }
  }
});
