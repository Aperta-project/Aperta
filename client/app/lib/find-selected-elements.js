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

/**
 *  Find element nodes within user selected text
 *  Modified from: https://github.com/yabwe/medium-editor
 */

export default function () {
  const selection = document.getSelection();

  if (
    !selection.rangeCount ||
    selection.isCollapsed ||
    !selection.getRangeAt(0).commonAncestorContainer
  ) {
    return [];
  }

  const range = selection.getRangeAt(0);

  if (range.commonAncestorContainer.nodeType === 3) {
    let toRet = [];
    let currNode = range.commonAncestorContainer;

    while (currNode.parentNode && currNode.parentNode.childNodes.length === 1) {
      toRet.push(currNode.parentNode);
      currNode = currNode.parentNode;
    }

    return toRet;
  }

  const elements = range.commonAncestorContainer.getElementsByTagName('*');
  const isFunction = typeof selection.containsNode === 'function';

  return _.filter(elements, function(element) {
    return isFunction ? selection.containsNode(element, true) : true;
  });
}
