/* jshint unused: false */

import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.Namespace.create({
  pathFor(model) {
    let adapter = model.get('store').adapterFor(model);
    let resourceType = model.constructor.modelName;
    return adapter.buildURL(resourceType, model.get('id'));
  },

  ajaxPromise(method, path, data) {
    let socketId = window.Tahi.__container__.lookup('pusher:main').get('socketId');

    return new Ember.RSVP.Promise(function(resolve, reject) {
      return Ember.$.ajax({
        url: path,
        type: method,
        data: data,
        success: resolve,
        error: reject,
        headers: {
          'PUSHER_SOCKET_ID': socketId
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
    return this.putModel(model, path).then(function(response) {
      return model.get('store').pushPayload(response);
    }, function(xhr) {
      let errors, modelErrors;

      if (errors = xhr.responseJSON.errors) {
        errors = Utils.camelizeKeys(errors);
        modelErrors = model.get('errors');
        Object.keys(errors).forEach(function(key) {
          return modelErrors.add(key, errors[key]);
        });
      }

      throw {
        status: xhr.status,
        model: model
      };
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
