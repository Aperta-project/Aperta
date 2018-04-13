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
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';

export default AuthorizedRoute.extend({
  afterModel(model, transition) {
    return this.get('can').can('manage_workflow', model).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      } else {
        return model.get('tasks');
      }
    });
  },

  actions: {
    // Required until Ember has routable components.
    // We need to cleanup because controllers are singletons
    // and are not torn down:

    willTransition() {
      this.controllerFor('paper.workflow').setProperties({
        taskToDisplay: null,
        showTaskOverlay: false
      });
    }
  }
});
