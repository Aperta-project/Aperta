/**
 *  Find an object within a linked hierachy that contains the
 *  sought-after keyName.
 */

import Ember from 'ember';

export default function (root, keyName, link='parentView') {
  var object = root;

  do {
    Ember.assert(`Property ${keyName} missing in ${link} hierarchy`, object);
    // window.console.log('Checking nearest', keyName, object);
    if (object.hasOwnProperty(keyName)) {
      return object.get(keyName);
    }

    object = object.get(link);
  } while (object);

  // window.console.log('Scenario for', keyName, 'not found');
  return null;
}
