import DS from 'ember-data';
import getOwner from 'ember-getowner-polyfill';

export default DS.ActiveModelAdapter.extend({
  namespace: 'api',
  headers: function() {
    return {
      namespace: 'api',
      'PUSHER_SOCKET_ID': getOwner(this).lookup('pusher:main').get('socketId')
    };
  }.property().volatile(),

  ajaxError: function(event, jqXHR, ajaxSettings, thrownError) {
    let status     = jqXHR.status;

    // don't blow up in case of a 403 from rails
    if (status === 403 || event.status === 403) { return; }

    return this._super(...arguments);
  }
});
