import getOwner from 'ember-getowner-polyfill';
import ActiveModelAdapter from 'active-model-adapter';

export default ActiveModelAdapter.extend({
  namespace: 'api',
  headers: function() {
    return {
      namespace: 'api',
      // Weird capitalization and hyphens are intentional since this is is an
      // HTTP header name. Whatever you do, DO NOT add underscores to the header
      // name because nginx will start to ignore it.
      'Pusher-Socket-ID': getOwner(this).lookup('pusher:main').get('socketId')
    };
  }.property().volatile(),

  ajaxError: function(event, jqXHR, ajaxSettings, thrownError) {
    const status = jqXHR.status;

    // don't blow up in case of a 403 from rails
    if (status === 403 || event.status === 403) { return; }

    return this._super(...arguments);
  }
});
