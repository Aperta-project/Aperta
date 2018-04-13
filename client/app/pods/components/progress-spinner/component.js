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
 *   ## How to Use
 *
 *   In your template:
 *
 *   ```
 *    {{progress-spinner visible=someBoolean color="green" size="small"}}
 *   ```
 *
 *   In your controller or component toggle the boolean:
 *
 *   ```
 *    this.set('someBoolean', true);
 *   ```
 **/

const computedConcat = function(string, dependentKey) {
  return Ember.computed(dependentKey, function(){
    let value = Ember.get(this, dependentKey);

    if(Ember.isEmpty(value)) { return null; }
    return string + Ember.get(this, dependentKey);
  });
};

export default Ember.Component.extend({
  classNames: ['progress-spinner'],
  classNameBindings: [
    '_visibleClass',
    '_colorClass',
    '_sizeClass',
    '_alignClass',
    'center:progress-spinner--absolute-center', // change to `absoluteCenter`
  ],

  /**
   *  Toggles visibility
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   **/
  visible: false,

  _visibleClass: Ember.computed('visible', 'align', function() {
    if(!this.get('visible')) { return; }

    let modifier = !this.get('align') ? 'inline' : 'block';
    return 'progress-spinner--' + modifier;
  }),

  /**
   *  Color. `green` or `blue` or `white`
   *
   *  @property color
   *  @type String
   *  @default green
   **/
  color: 'green',
  _colorClass: computedConcat('progress-spinner--', 'color'),

  /**
   *  Size. `small` or `large`
   *
   *  @property size
   *  @type String
   *  @default small
   **/
  size: 'small',
  _sizeClass: computedConcat('progress-spinner--', 'size'),

  /**
   *  If true, absolute positioning is used to center vertically and horizontally
   *
   *  @property center
   *  @type boolean
   *  @default false
   **/
  // TODO: this should be renamed to something like "absoluteCenter"
  center: false,

  /**
   *  If set, spinner becomes a block level element.
   *  Options are `middle`
   *
   *  @property align
   *  @type String
   *  @default null
   **/
  align: null,
  _alignClass: computedConcat('progress-spinner--', 'align')
});
