import Ember from 'ember';

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

  fetch() {
    if(!isEmpty(this.get('_data'))) { return; }
    this._didStartLoading();

    this.get('restless').get('/api/countries').then((response)=> {
      if(this.get('isDestroying')) { return; }
      this.set('_data', response.countries);
      this._didLoad();
    }, ()=> {
      this._didError();
    });
  },

  _didStartLoading() {
    Ember.run.schedule('afterRender', () => {
      if (!this.get('isDestroying')) {
        this.setProperties({
          loaded: false,
          loading: true,
          error: false
        });
      }
    });
  },

  _didError() {
    Ember.run.schedule('afterRender', () => {
      if (!this.get('isDestroying')) {
        this.setProperties({
          loaded: false,
          loading: false,
          error: true
        });
      }
    });
  },

  _didLoad() {
    Ember.run.schedule('afterRender', () => {
      if (!this.get('isDestroying')) {
        this.setProperties({
          loaded: true,
          loading: false,
          error: false
        });
      }
    });
  }
});
