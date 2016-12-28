import Ember from 'ember';
import ActiveModelAdapter from 'active-model-adapter';

const { getOwner } = Ember;

export default ActiveModelAdapter.extend({
  namespace: 'api',
  headers: function() {
    Ember.assert(`Can't find the pusher service.  Most likely you're seeing this error in a test environment, and
                 Ember is making an ajax request for a resource you haven't stubbed, like a permissions check for a task.
                 If you go up the stack trace to the restAdapter (rest.js) you can see the url for the request.  If you're trying
                 to fetch a permission, you can either stub the request itself, or ideally you can use the FakeCanService to prevent
                 the request from ever going out in the first place.  See \`test/helpers/fake-can-service.js\``, getOwner(this).lookup('pusher:main'));
    return {
      namespace: 'api',
      // Weird capitalization and hyphens are intentional since this is is an
      // HTTP header name. Whatever you do, DO NOT add underscores to the header
      // name because nginx will start to ignore it.
      'Pusher-Socket-ID': getOwner(this).lookup('pusher:main').get('socketId')
    };
  }.property().volatile(),

  handleResponse(status) {
    if ( status === 401 ) {  return document.location.href = '/users/sign_in';  }
    return this._super(...arguments);
  },

  ajaxError: function(event, jqXHR, ajaxSettings, thrownError) {
    const status = jqXHR.status;

    // don't blow up in case of a 403 from rails
    if (status === 403 || event.status === 403) { return; }

    return this._super(...arguments);
  },

  // buildURLForModel is a custom hook added by Aperta. It's so the URL
  // for a given model/instance can be generated and overriden. See
  // adapters/paper.js for an example.
  buildURLForModel(model){
    let id = model ? Ember.get(model, 'id') : null;
    let type = model.constructor.modelName
    return this.buildURL(type, id);
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
