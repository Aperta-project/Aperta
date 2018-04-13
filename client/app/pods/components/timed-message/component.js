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
  {{timed-message message=reallyImportantMessage
                  class="custom-class-here"
                  duration=8000}}
  ```

  In your controller or component set the message:

  ```
  save: function() {
    this.get('model').save().then(() => {
      this.set('reallyImportantMessage', 'You did good');
    });
  }
  ```
*/

export default Ember.Component.extend({
  /**
    Length of time in miliseconds before message is removed

    @property duration
    @type number
    @default 5000
  */

  duration: 5000,

  /**
    Text displayed to user

    @property message
    @type String
    @default ''
  */

  message: '',

  messageDidChange: Ember.observer('message', function() {
    this.$().html(this.get('message'));

    Ember.run.later(this, function() {
      if(!this.get('isDestroyed')) {
        this.set('message', '');
      }
    }, this.get('duration'));
  })
});
