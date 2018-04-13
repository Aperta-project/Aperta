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
 *  OverlayFullscreen wraps up three other components:
 *  ember-wormhole, overlay-animate, and overlay-fullscreen-layout
 *  It also handles when an overlay is shown or hidden.
 *
 *  ## How it works
 *
 *  `ember-wormhole` renders the overlay at the root of the DOM tree
 *
 *  `overlay-animate` handles animations
 *
 *  `overlay-fullscreen-layout` handles markup and styles and
 *  yields a hash that contains overlay properties, like `animateOut`
 *
 *  Basic working example:
 *  @example
 *    {{#overlay-fullscreen visible=showMyOverlay
 *                          outAnimationComplete=(action "hideMyOverlay")
 *                          title="My Stuff"
 *                          overlayClass="my-stuff-overlay"
 *                          as |overlay|}}
 *        {{my-stuff close=(action overlay.animateOut)}}
 *    {{/overlay-fullscreen}}
 *
 *  The lifecycle should go like this:
 *
 *  1.  User somehow triggers `showMyOverlay` in the controller
 *  2.  `overlay-fullscreen` `visible` property is changed,
 *      rendering everything in its template
 *  3.  `ember-wormole` renders `animate-overlay` with
 *      the component at the DOM root
 *  4.  `animate-overlay` animates in the component
 *  5.  ...
 *  6.  User somehow triggers `close` action
 *      (save button, escape key, click "X", etc.)
 *  7.  `animate-overlay` animates out the component
 *  8.  `animate-overlay` calls `outAnimationComplete` callback
 *  9.  This callback from the controller toggles a property
 *  10. `overlay-fullscreen` `visible` property is changed,
 *      removing everything in its template from the DOM
 *
 *  @class OverlayFullscreenComponent
 *  @extends Ember.Component
 *  @since 1.3.5+
**/

export default Ember.Component.extend({
  /**
   *  ID of DOM element overlay will be rendered in.
   *  This attribute is passed to `ember-wormhole`
   *
   *  @property to
   *  @type String
   *  @default 'overlay-drop-zone'
   *  @required
  **/
  to: 'overlay-drop-zone',


  /**
   * Tells the overlay whether or not to use ember-wormhole
   *  @property wormhole
   *  @type Boolean
   *  @default true
   **/
  wormhole: true,

  /**
   *  Text that will be displayed as the overlay title.
   *  This property is passed to `overlay-fullscreen-layout`.
   *  Leaving this property as null will not put the heading
   *  node in the DOM. If special formatting is required, leave
   *  this null and put the markup in the component template
   *
   *  @property title
   *  @type String
   *  @default null
   *  @optional
  **/
  title: null,

  /**
   *  Additional classes for overlay DOM node.
   *  This attribute is passed to `overlay-fullscreen-layout`
   *
   *  @property overlayClass
   *  @type String
   *  @default null
   *  @optional
  **/
  overlayClass: null,

  /**
   *  Method called after out animation is complete.
   *  This should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method outAnimationComplete
   *  @required
  **/
  outAnimationComplete: null,

  /**
   *  Method called after in animation is complete.
   *  This should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method inAnimationComplete
   *  @optional
  **/
  inAnimationComplete(){},

  /**
   *  Toggle insertion of overlay into DOM
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   *  @required
  **/
  visible: false,
  enableClose: true,

  init() {
    this._super(...arguments);
    Ember.assert(
      `You must provide an outAnimationComplete
       action to OverlayFullscreenComponent`,
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );
  }
});
