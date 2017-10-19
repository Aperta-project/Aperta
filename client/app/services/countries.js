import Ember from 'ember';
import { task } from 'ember-concurrency';

const {
  computed,
  inject: { service },
  isEmpty,
  Service
} = Ember;

export default Service.extend({
  restless: service('restless'),

  loaded: false,
  loading: false,
  error: false,

  _data: [],
  data: computed({
    get() {
      if(isEmpty(this.get('_data'))) {
        this.fetch();
      }

      return this.get('_data');
    },

    set(key, value) {
      this.set('_data', value);
    }
  }),

  fetch: task(function * () {
    try {
      this.set('loading', true);
      const response = yield this.get('restless').get('/api/countries');
      this.set('_data', response.countries);
      this.set('loaded', true);
      this.set('loading', false);
    } catch(e) {
      this.set('loading', false);
      this.set('error', true);
      throw(e);
    }
  })
});
