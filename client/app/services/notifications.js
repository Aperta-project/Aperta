import Ember from 'ember';
import EmberPusher from 'ember-pusher';

export default Ember.Service.extend(Ember.Evented, EmberPusher.Bindings, {
  restless: Ember.inject.service(),

  data: [],

  init() {
    this._super(...arguments);

    this.pusherSetup();

    this.fetchData().then(response => {
      this.set('data', response.notifications);
    });
  },

  fetchData() {
    return this.get('restless').get('/api/notifications/');
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

  remove(options) {
    const { type, id } = options;
    const remove = this.getData(type, parseInt(id));
    this.get('data').removeObjects(remove);

    // const ids = remove.map(function(n) {
    //   return n.id;
    // });

    // this.get('restless')
    //     .get('/api/notifications/destroy?ids=[' + ids.toString() + ']');
  },

  getData(type, id) {
    return this.get('data').filter(n => {
      if(id && type && type === 'paper') {
        return n.paper_id === id;
      }

      if(type && id) {
        return n.target_id === id && n.target_type === type;
      }
    });
  },

  getCount(type, id) {
    return this.getData(type, id).get('length');
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
