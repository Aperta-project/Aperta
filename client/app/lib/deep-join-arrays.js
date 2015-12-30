import Ember from 'ember';

const { isArray } = Ember;

export default function(hash) {
  const spelunk = function(thing) {
    Object.keys(thing).forEach(function(key) {
      if (!thing || typeof thing !== 'object') {
        return thing;
      }
      if (isArray(thing[key])) {
        thing[key] = thing[key].join(', ');
      } else {
        spelunk(thing[key]);
      }
    });

    return thing;
  };

  return spelunk(hash);
}
