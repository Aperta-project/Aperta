import Ember from 'ember';
import EmberPusher from 'ember-pusher';

export default Ember.Service.extend(Ember.Evented, EmberPusher.Bindings, {
  restless: Ember.inject.service(),

  data: [],

  init() {
    this._super(...arguments);

    this.pusherSetup();

    const data = this.fetchData();

    this.set('data', data.notifications);
    // this.fetchData().then(data => {
    //   this.set('data', data.notifications);
  },

  fetchData() {
    return {
      'notifications': [
        {
          id: 1,
          paper_id: 11,
          target_type: 'DiscussionTopic',
          target_id: 2
        }
      ]
    };
    // return this.get('restless')
    //            .get('/api/notifications/');
  },

  pusherSetup() {
    this.get('pusher').wire(this,
      'private-user@' + this.get('currentUser.id'),
      ['created', 'destroyed']
    );
  },

  filterBy(key, id) {
    return this.get('data').filterBy(key, parseInt(id));
  },

  actions: {
    created(payload) {
      console.log(payload.type);
      this.trigger('update');
    },

    destroyed(payload) {
      console.log(payload.type);
      this.trigger('update');
    }
  }
});
