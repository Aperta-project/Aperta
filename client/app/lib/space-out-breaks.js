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

export default function (string) {
  // This function is intended to change HTML breaks to spaces. It achieves this
  // by doing two things.
  //
  // 1. Replace HTML breaks with a space
  //    a. [edge-case] the break may have spaces before and after. This should
  //       only be replaced with one space.
  //
  // Regular Expression Clauses (in order)
  // 1. Replace HTML <br> tags with a single space.
  // 2. Similar to "trim"
  // 3. Similar to "squeeze" - one space separators - for non <pre>, <code> tags
  // 4. Remove line-breaks and carriage-returns
  //
  // Note, the "squeeze" replacement filter would squeeze out multiple spaces
  // within <pre> and <code> tags. This is not desirable, but is beyong the
  // scope of APERTA-10600 which this library was created for. Also, the
  // scenario this is used is when **a piece of HTML is to be displayed in one
  // line.**
  if (string) {
    return string.replace(/<br\/?(>|$)/g, ' ')
                 .replace(/^\s+|\s+$/g, '')
                 .replace(/\s+/g, ' ')
                 .replace(/(<[^\/|pre|code]+>)\s+/g, '$1')
                 .replace(/[\n\r]/g, '');
  }
  return '';
}
