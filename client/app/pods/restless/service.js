/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

/* jshint unused: false */

import Ember from 'ember';
import camelizeKeys from 'tahi/lib/camelize-keys';

const { getOwner } = Ember;

export default Ember.Service.extend({
  store: Ember.inject.service(),

  pathFor(model) {
    let adapter = model.get('store').adapterFor(model.constructor.modelName);
    let resourceType = model.constructor.modelName;
    return adapter.buildURLForModel(model);
  },

  /**
   * The restless service's ajaxPromise method defers to the Application Adapter
   * to actually make its API requests.
   *
   * The Application adapter takes care of setting the headers (like the pusher
   * socket id) that the API expects. It will also hand off some error handling
   * to ember data if the request is unsuccessful.
   */
  ajaxPromise(method, path, data) {
    let adapter = Ember.get(this, 'store').adapterFor('application');
    return adapter.ajax(path, method, { data });
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
