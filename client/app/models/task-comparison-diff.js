import Ember from 'ember';

export default Ember.Object.extend({
  old: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      { type: "properties", name: "authors", children: [
        { type: "properties", name: "author", children: [
            {type: "text", name: "first_name", value: "John"},
            {type: "text", name: "last_name", value: "Smith"},
            {type: "text", name: "suffix", value: "Jr."}
          ]
        },

        // { type: "properties", name: "author", children: [
        //     {type: "text", name: "first_name", value: "Sally"},
        //     {type: "text", name: "last_name", value: "Doe"},
        //   ]
        // }
      ] // authors
      }
    ]  // properties
  }, // old

  new: {
    version: "4.5",
    date: "2015-09-01",

    properties: [
      { type: "properties", name: "authors", children: [
        { type: "properties", name: "author", children: [
            {type: "text", name: "salutation", value: "Mr."},
            {type: "text", name: "first_name", value: "John"},
            {type: "text", name: "last_name", value: "Doe"},

          ]
        },
        //
        // { type: "properties", name: "author", children: [
        //     {type: "text", name: "first_name", value: "Paul"},
        //     {type: "text", name: "last_name", value: "John"},
        //   ]
        // }
      ] // authors
      }
    ]  // properties

  }, // new

  diffProperties: function(oldProperties, newProperties){
    let result = [];
    let leftProperties = oldProperties; //_.zip(oldProperties);
    let rightProperties = newProperties; //_.zip(newProperties);

    let left = 0; let right = 0;
    while (left < leftProperties.length || right < rightProperties.length) {
      let leftProperty = leftProperties[left];
      let rightProperty = rightProperties[right];

      if (left >= leftProperties.length) {
        result.push( this.diffProperty(null, rightProperty) );
        right++;
      }
      else if (right >= rightProperties.length) {
        result.push( this.diffProperty(leftProperty, null) );
        left++;
      }
      else if (leftProperties[left].type === rightProperties[right].type &&
          leftProperties[left].name === rightProperties[right].name) {
            // diffProperty
            result.push( this.diffProperty(leftProperty, rightProperty) );
            left++;
            right++;
      } else if (this.wasRemoved(leftProperties[left], right, rightProperties)) {
        result.push( this.diffProperty(leftProperty, null) );
        left++;

      } else if (this.wasInserted(rightProperties[right], left, leftProperties)) {
        result.push( this.diffProperty(null, rightProperty) );
        right++;

      } else {
        right++;
      }
    }

    return result;
  },

  wasRemoved: function(ourProperty, index, fromProperties) {
    var i = index;

    for (i; i < fromProperties.length; i++) {
      if (fromProperties[i].type === ourProperty.type &&
          fromProperties[i].name === ourProperty.name) {
            return false;
          }
    }

    return true;
  },

  wasInserted: function(ourProperty, index, fromProperties) {
    var i = index;
    for (i; i < fromProperties.length; i++) {
      if (fromProperties[i].type === ourProperty.type &&
          fromProperties[i].name === ourProperty.name) {
            return false;
          }
    }
    return true;
  },

  diffProperty: function(oldProperty, newProperty) {
    if(oldProperty && !newProperty){
      newProperty = { type: oldProperty.type, value: "", children: [] };
    } else if(!oldProperty && newProperty){
      oldProperty = { type: newProperty.type, value: "", children: [] };
    }

    if(oldProperty.type === "properties"){
      return this.diffProperties(oldProperty.children, newProperty.children);
    } else if(oldProperty.type === "text"){
      let diff = JsDiff.diffWords(oldProperty.value.toString(), newProperty.value.toString());
      return diff;
    } else if (oldProperty.type === "boolean") {
      let diff = JsDiff.diffWords(oldProperty.value.toString(), newProperty.value.toString());
      return diff;
    }
  },

  diff: Ember.computed(function(){
    let results = this.diffProperties(this.old.properties, this.new.properties);
    return results;
    //  [
    //   { hasDifference: true, oldValue: "Bob", newValue: "Lenny" }
    // ];
  })
});
