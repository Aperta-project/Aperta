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
import PaperBase from 'tahi/mixins/controllers/paper-base';

export default Ember.Component.extend(PaperBase, {
  elementId: 'versioning-bar',
  classNames: ['versions', 'active'],

  actions: {
    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set(
        'selectedVersion1',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);

      this.attrs.setQueryParam(
        'selectedVersion1', this.get('selectedVersion1')
      );
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.set(
        'selectedVersion2',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
      let action = this.get('setQueryParam');
      action('selectedVersion2', this.get('selectedVersion2'));
    }
  }
});
