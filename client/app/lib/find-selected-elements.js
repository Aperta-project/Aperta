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
