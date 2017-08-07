/**
 *  Find an object within a linked hierachy that contains the
 *  sought-after keyName.
 */

import Ember from 'ember';

export default function (root, keyName, link='parentView') {
  var object = root;

  do {
    Ember.assert(`Property ${keyName} missing in ${link} hierarchy`, object);
    window.console.log('Checking nearest', object);
    if (object.hasOwnProperty(keyName)) {
      return object[keyName];
    }

    object = object[link];
  } while (object);

  return null;
}
