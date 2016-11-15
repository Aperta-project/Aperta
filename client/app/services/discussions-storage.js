import Ember from 'ember';

const BUCKET = 'aperta';
// keep comment cache around for 30 days
const STORAGE_LENGTH = ((60*24)*30);

export default Ember.Service.extend({
  getItem(key) {
    window.lscache.setBucket(BUCKET);
    return window.lscache.get('discussion:' + key);
  },

  setItem(key, value) {
    window.lscache.setBucket(BUCKET);
    window.lscache.set('discussion:' + key, value, STORAGE_LENGTH);
  },

  removeItem(key) {
    window.lscache.setBucket(BUCKET);
    window.lscache.remove('discussion:' + key);
  }
});
