import Ember from 'ember';

export default function(hash) {
  const spelunk = function(thing) {
    if (!thing || typeof thing !== 'object') { return thing; }

    if (Ember.isArray(thing)) { return thing.map(spelunk); }

    return Object.keys(thing).reduce(function(previousValue, key) {
      const toS = Object.prototype.toString.call(thing[key]);
      const isDate = toS === '[object Date]';
      const camelizedKey = Ember.String.camelize(key);

      previousValue[camelizedKey] = (isDate ? thing[key] : spelunk(thing[key]));

      return previousValue;
    }, {});
  };

  return spelunk(hash);
}
