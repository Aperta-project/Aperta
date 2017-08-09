/**
 *  Find an object within a linked hierachy that contains the
 *  sought-after keyName.
 */

import Ember from 'ember';

export default function (root, keyName, link='parentView') {
  var object = root;

  do {
    Ember.assert(`Property ${keyName} missing in ${link} hierarchy`, object);
    let value = object.get(keyName);
    if (value) {
      return value;
    }

    object = object.get(link);
  } while (object);

  return null;
}
