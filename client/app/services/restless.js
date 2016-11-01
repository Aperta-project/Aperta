/* jshint unused: false */

import Ember from 'ember';
import camelizeKeys from 'tahi/lib/camelize-keys';

const { getOwner } = Ember;

export default Ember.Service.extend({
  pathFor(model) {
    let adapter = model.get('store').adapterFor(model.constructor.modelName);
    let resourceType = model.constructor.modelName;
    return adapter.buildURL(resourceType, model.get('id'));
  },

  ajaxPromise(method, path, data) {
    let pusher = getOwner(this).lookup('pusher:main');
    let socketId = null;
    if (pusher) {
      socketId = getOwner(this).lookup('pusher:main').get('socketId');
    }

    let contentType = 'application/x-www-form-urlencoded; charset=UTF-8';
    if (method !== 'GET') {
      contentType = 'application/json';
      data = JSON.stringify(data);
    }

    return new Ember.RSVP.Promise(function(resolve, reject) {
      return Ember.$.ajax({
        url: path,
        type: method,
        data: data,
        contentType: contentType,
        success: resolve,
        error: reject,
        headers: {
          'Pusher-Socket-ID': socketId
        },
        dataType: 'json'
      });
    });
  },

  'delete': function(path, data) {
    return this.ajaxPromise('DELETE', path, data);
  },

  put(path, data) {
    return this.ajaxPromise('PUT', path, data);
  },

  post(path, data) {
    return this.ajaxPromise('POST', path, data);
  },

  get(path, data) {
    return this.ajaxPromise('GET', path, data);
  },

  putModel(model, path, data) {
    return this.put('' + (this.pathFor(model)) + path, data);
  },

  putUpdate(model, path, data) {
    // set the model's state to 'updated.inFlight' so we can ask if it's 'isSaving'
    model.send('willCommit');
    return this.putModel(model, path, data).then(function(response) {
      return model.get('store').pushPayload(response);
    }, function(xhr) {
      let modelErrors;

      let errors = xhr.responseJSON.errors;
      if (errors) {
        errors = camelizeKeys(errors);
        modelErrors = model.get('errors');
        Object.keys(errors).forEach(function(key) {
          return modelErrors.add(key, errors[key]);
        });
      }

      throw {
        status: xhr.status,
        model: model
      };
    }).finally(() => {
      // for now always send 'didCommit' rather than sending 'becameError' on error
      // in order to avoid possibly breaking in some other places
      model.send('didCommit');
    });
  },

  authorize(controller, url, property) {
    let authorize = function(value) {
      return function(result) {
        return Ember.run(function() {
          return controller.set(property, value);
        });
      };
    };

    return Ember.$.ajax(url, {
      success: authorize(true),
      error: authorize(false)
    });
  }
});
