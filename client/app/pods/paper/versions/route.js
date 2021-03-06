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

var PaperVersionsRoute = AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  afterModel(model) {
    return Ember.RSVP.all([
      model.get('tasks'),
      model.get('versionedTexts'),
      model.get('snapshots')]);
  },

  setupController(controller, model) {
    controller.set('model', model);
    controller.set('subRouteName', 'versions');

    /*
     This logic covers three cases when entering the Versions screen
     1. The first time when `selectedVersion1` does not exist
     2. When `selectedVersion1` is a draft so the numbers are null
     3. When `selectedVersion1` is a previous version
     */
    const viewingVersionText = controller.get('selectedVersion1');

    if (viewingVersionText && !this.versionTextIsDraft(viewingVersionText)) {
      controller.set('viewingVersion', model.textForVersion(viewingVersionText));
    } else {
      // `selectedVersion1` was undefined or a draft
      let latest = model.get('versionedTexts').objectAt(0);
      controller.set('viewingVersion', latest);
      controller.set('selectedVersion1', this.versionText(latest));
    }

    if (controller.get('selectedVersion2')) {
      controller.set('comparisonVersion', model.textForVersion(
        controller.get('selectedVersion2')
      ));
    }
  },

  versionText(version) {
    return version.get('majorVersion') +
           '.' +
           version.get('minorVersion');
  },

  versionTextIsDraft(text) {
    if(text === undefined || text.match('null')) {
      return true;
    }

    return false;
  },

  actions: {
    exitVersions() {
      this.transitionTo('paper.index', this.modelFor('paper'));
    },

    // Required until Ember has routable components.
    // We need to cleanup because controllers are singletons
    // and are not torn down:

    willTransition() {
      this.controllerFor('paper.versions').setProperties({
        taskToDisplay: null,
        showTaskOverlay: false
      });
    }
  }
});

export default PaperVersionsRoute;
