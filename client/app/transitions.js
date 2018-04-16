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

export default function() {
  const discussionsOptions = { duration: 600, easing: [300, 25] };
  const discussionsNew = function(routeName) {
    return (/paper\.[^.]*\.discussions\.new/).test(routeName);
  };
  const discussionsShow = function(routeName) {
    return (/paper\.[^.]*\.discussions\.show/).test(routeName);
  };
  const discussionsIndex = function(routeName) {
    return (/paper\.[^.]*\.discussions\.index/).test(routeName);
  };

  this.transition(
    this.fromRoute(discussionsIndex),
    this.toRoute(discussionsShow),
    this.use('slideToLeft', discussionsOptions),
    this.reverse('slideToRight', discussionsOptions)
  );

  this.transition(
    this.toRoute(discussionsNew),
    this.use('slideToLeft', discussionsOptions),
    this.reverse('slideToRight', discussionsOptions)
  );

  this.transition(
    this.childOf('#figure-list'),
    this.use('explode', {
      matchBy: 'data-figure-id',
      use: ['fly-to', {duration: 600, easing: 'easeOutCubic'}]
    })
  );

  this.transition(
    this.hasClass('card-fade'),
    this.use('fade', { duration: 300 })
  );
}
