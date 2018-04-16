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

/**
  ## How to Use

  In your template:

  ```
  {{#segmented-buttons selectedValue=sortBy action="setSortOrder"}}
    {{#segmented-button value="old"}}Sort by Oldest{{/segmented-button}}
    {{#segmented-button value="new"}}Sort by Newest{{/segmented-button}}
  {{/segmented-buttons}}
  ```

  In your component or route:

  ```
  actions: {
    setSortOrder(value) {
      this.set('sortBy', value);
    }
  }
  ```


  ## How it Works

  When a child `segmented-button` component is pressed, the `value` property of that component is
  sent up through the action defined on this `segmented-buttons` component.
  The `value` property of a clicked child segmented-button component is passed to the action set on the segmented-buttons component.
  A parent component or route is expected to catch this action and change the `selectedValue` property.
*/

export default Ember.Component.extend({
  classNames: ['segmented-buttons'],

  /**
   * @property selectedValue
   * @type Anything
   * @default null
   * @required
   */
  selectedValue: null,

  /**
    Method called by child `segmented-button` components

    @method valueSelected
    @param {String} value to be set to `selectedValue`
  */
  valueSelected(value) {
    this.sendAction('action', value);
  }
});
