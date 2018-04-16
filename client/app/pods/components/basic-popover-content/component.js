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

import BasicDropdownContent from 'ember-basic-dropdown/components/basic-dropdown/content';

export default BasicDropdownContent.extend({
  class: 'popover-menu',

  init() {
    this._super(...arguments);
    const self = this;
    $('body').on('click.basic-popover-content', function(e) {
      self.handleContentClick(e);
    });
  },

  handleContentClick(e) {
    const clickedInPopover = $(e.target).closest('.ember-basic-dropdown-content');
    if(clickedInPopover.length) {
      this.get('dropdown').actions.close();
    }
  },

  willDestroyElement() {
    this._super(...arguments);
    $('body').off('click.basic-popover-content');
  }
});
