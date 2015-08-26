import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Service.extend({
  loaded: false,
  loading: false,
  error: false,

  _data: [],
  data: Ember.computed({
    get() {
      if(Ember.isEmpty(this.get('_data'))) { return this.fetch(); }
      return this.get('_data');
    },

    set(key, value) {
      this.set('_data', value);
    }
  }),

  fetch() {
    this._didStartLoading();

    RESTless.get('/api/countries').then((response)=> {
      this.set('_data', response.countries);
      this._didLoad();
    }, ()=> {
      this._didError();
    });
  },

  _didStartLoading() {
    this.setProperties({
      loaded: false,
      loading: true,
      error: false
    });
  },

  _didError() {
    this.setProperties({
      loaded: false,
      loading: false,
      error: true
    });
  },

  _didLoad() {
    this.setProperties({
      loaded: true,
      loading: false,
      error: false
    });
  }
});
