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

// Facilitates display of a warning overlay when navigating away from a dirty editor.
// Used in conjuction with client/app/mixins/components/dirty-editor-ember.js
export default Ember.Mixin.create({
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('dirtyEditorConfig', this.get('dirtyEditorConfig'));
  },

  actions: {
    willTransition(transition) {
      let model = this.currentModel;
      let props = this.get('dirtyEditorConfig.properties');
      let dirtyAndRelevant = props.any((item) => model.changedAttributes()[item]);
      let hasDirty = !!(model.get('hasDirtyAttributes') && dirtyAndRelevant);

      if (!hasDirty) {
        return true;
      }

      this.set('previousTransition', transition);
      transition.abort();
      this.set('controller.showDirtyOverlay', true);
    },

    retryStoppedTransition() {
      this.set('controller.showDirtyOverlay', false);
      this.get('previousTransition').retry();
    }
  }
});
