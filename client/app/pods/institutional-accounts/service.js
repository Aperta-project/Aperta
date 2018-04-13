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

    this.get('restless').get('/api/institutional_accounts').then((response)=> {
      this.set('_data', response.institutional_accounts);
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
