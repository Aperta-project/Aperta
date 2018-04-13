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
import AuthorizedRoute from 'tahi/pods/authorized/route';

export default AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  queryParams: {
    page: {
      refreshModel: true
    },
    orderBy: {
      refreshModel: true
    },
    orderDir: {
      refreshModel: true
    },
    query: {
      refreshModel: true
    },
  },

  beforeModel(transition) {
    this.set('transition', transition);
  },

  model(params) {
    return this.get('restless').get('/api/paper_tracker', params).then((data)=> {
      this.prepMetaData(data);
      this.store.pushPayload('paper', data);
      let paperIds = data.papers.mapBy('id');
      return _.collect(paperIds, (id) => {
        return this.store.findRecord('paper', id);
      });
    }, (reason) => {
      if (reason.status === 403) {
        return this.handleUnauthorizedRequest(this.get('transition'));
      } else {
        // Have to add the flash message after the transition has finished.
        Ember.run.later(() => {
          this.flash.displayRouteLevelMessage(
              'error',
              'Sorry, I don\'t understand how to perform that search');});
        return [];
      }
    });
  },

  setupController(controller, model) {
    this._super(controller, model);
    this.store.findAll('comment-look');
    this.setControllerData(controller);
  },

  metaData: null, // comes in payload, must be plucked for use in setupController

  prepMetaData(data) {
    if (data.meta) {
      this.set('metaData', data.meta);
      delete data.meta; // or pushPayload craps
    }
  },

  setControllerData(controller) {
    controller.set('page', this.get('metaData.page'));
    controller.set('totalCount', this.get('metaData.totalCount'));
    controller.set('perPage', this.get('metaData.perPage'));
    controller.set('paperTrackerQueries',
                   this.store.findAll('paper-tracker-query'));
  },

  actions: {
    didTransition: function() {
      //keeps search box up to date if entering url cold
      this.controller.set('queryInput', this.controller.get('query'));
      return true; // Bubble the didTransition event
    }
  }
});
