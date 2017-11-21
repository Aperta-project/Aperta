export function compareJson(snapshot1, snapshot2) {
  if (snapshot1.constructor !== snapshot2.constructor || (snapshot1.constructor !== String && snapshot1.constructor !== Object && snapshot1.constructor !== Array)) {
    return false;
  }

  let result = false;

  if (snapshot1.constructor === String) {
    return snapshot1 === snapshot2;
  }
  else if (snapshot1.constructor === Array) {
    if (snapshot1.length === 0 && snapshot2.length === 0) {
      return true;
    }
    //let checkFields = ['owner_type', 'owner_id', 'grant_number', 'website', 'additional_comments'];
    //let ignoreFields = ['name', 'type', 'value'];

    //snapshot1 = cleanHash(snapshot1, checkFields, ignoreFields);
    //snapshot2 = cleanHash(snapshot2, checkFields, ignoreFields);

    snapshot1.forEach(function (current, index) {
      result = compareJson(current, snapshot2[index]);
      if (!result) {
        return;
      }
    });

  }
  else if (snapshot1.constructor === Object) {
    deleteKeys(snapshot1, ['id', 'answer_type']);
    deleteKeys(snapshot2, ['id', 'answer_type']);

    Object.keys(snapshot1).forEach(function (current) {
      let value1 = snapshot1[current];
      let value2 = snapshot2[current];

      if (Object.keys(snapshot2).indexOf(current) === -1) {
        return false;
      }

      if (snapshot1.constructor === Array || snapshot1.constructor === Object) {
        result = compareJson(value1, value2);
      }
      else {
        result = (value1 === value2);
      }
    });
  }
  return result;
}

let deleteKeys = function(snapshot, keys){
  keys.forEach(function(key){
    delete snapshot[key];
  });
};

// let cleanHash = function (snapshot, checkFields, ignoreFields) {
//   return snapshot;
// };
