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
import PositionNearMixin from 'tahi/mixins/components/position-near';

/**
 *  position-near is meant to be a light component for the position-near mixin
 *  - It is block style only (see example below)
 *  - It simply positions the contents of the block next to a DOM node
 *  - See PositionNearMixin for all options
 *
 *  @example
 *    {{#position-near positionNearSelector="#the-thing"}}
 *      Important Stuff Here
 *    {{/position-near}}
 *
 *  @class PositionNearComponent
 *  @extends Ember.Component
 *  @uses PositionNearMixin
 *  @since 1.3.0
**/

export default Ember.Component.extend(PositionNearMixin, {
  positionNearSelector: Ember.computed.alias('selector')
});
