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
  },


  // These hooks are described in the ember data 1.13 release post
  // http://emberjs.com/blog/2015/06/18/ember-data-1-13-released.html#toc_new-adapter-hooks-for-better-caching

  shouldReloadRecord () {
    return false;
  },

  // defaults to true in ember-data 2.0,
  // TODO: investigate returning `true` as part of #2466
  shouldBackgroundReloadRecord() {
    return false;
  },

  // pre-2.0 behavior is to reload records on a `findAll` call
  shouldReloadAll () {
    return true;
  },

  // defaults to true in ember-data 2.0,
  // TODO: investigate returning `true` as part of #2466
  shouldBackgroundReloadAll() {
    return false;
  }
});
