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
 *  select-native is a component for the html select element.
 *  - It will iterate over the content attr and yield each item,
 *    as an option element
 *  - The action attr should be an action that mutates
 *    the selection (see examples below)
 *
 *  The example below mutates the selectedPerson on-change
 *  @example
 *    {{select-native content=paper.versions
 *                    optionValuePath="id"
 *                    optionLabelPath="name"
 *                    selection=selectedPerson
 *                    action=(action (mut selectedPerson))}}
 *
 *  The example below calls an action from a parent component
 *  @example
 *    {{select-native content=paper.versions
 *                    optionValuePath="id"
 *                    optionLabelPath="name"
 *                    selection=selectedPerson
 *                    action=(action "someActionNameHere")}}
 *
 *  The example below uses an array as the data source
 *  (don't supply an optionValuePath or optionLabelPath path)
 *  @example
 *    {{select-native content=someArray
 *                    selection=selectedPerson
 *                    action=(action "someActionNameHere")}}
 *
 *  @class SelectNativeComponent
 *  @extends Ember.Component
 *  @since 1.3.0
**/

export default Ember.Component.extend({
  tagName: 'select',
  attributeBindings: [
    'autofocus',
    'disabled',
    'form',
    'name',
    'required',
    'size',
    'tabindex'
  ],

  // possible passed-in values with their defaults:
  content: null,

  /**
   *  Will display as first option, disabled.
   *  The prompt will be selected when a selection is not made
   *
   *  @property prompt
   *  @type String
   *  @default null
   *  @optional
  **/
  prompt: null,

  /**
   *  Will allow the prompt to be selected to clear selection
   *
   *  @property allowDeselect
   *  @type Boolean
   *  @default false
   *  @requires prompt
   *  @optional
  **/
  allowDeselect: false,

  /**
   *  @property _promptDisabled
   *  @requires allowDeselect
   *  @private
  **/
  _promptDisabled: Ember.computed('allowDeselect', function() {
    return this.get('allowDeselect') ? null : true;
  }),

  optionValuePath: null,
  optionLabelPath: null,
  action: Ember.K, // action to fire on change

  /**
   *  Shadow the passed-in `selection` to avoid
   *  leaking changes to it via a 2-way binding
   *
   *  @property _selection
   *  @private
  **/
  _selection: Ember.computed.reads('selection'),

  init() {
    this._super(...arguments);
    if (!this.get('content')) {
      this.set('content', []);
    }
  },

  /**
   *  Event fired when the selection is changed
   *
   *  @public
  **/
  change() {
    const selectEl = this.$()[0];
    const selectedIndex = selectEl.selectedIndex;
    const content = this.get('content');
    const hasPrompt = !!this.get('prompt');
    let selection;

    // decrement index by 1 if we have a prompt
    const contentIndex = hasPrompt ? selectedIndex - 1 : selectedIndex;

    if(hasPrompt && selectedIndex === 0) {
      // leave selection as undefined
    } else {
      selection = content.objectAt(contentIndex);
    }

    // set the local, shadowed selection to avoid leaking
    // changes to `selection` out via 2-way binding
    this.set('_selection', selection);

    const changeCallback = this.get('action');
    changeCallback(selection);
  }
});
