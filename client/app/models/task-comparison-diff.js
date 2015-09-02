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
            {type: "text", name: "suffix", value: "Jr."},
            {type: "question", name: "Hometown", value: { title: "Hometown", answer: "Grand Rapids"}}
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
            {type: "properties", name: "children", children: [
              {type: "text", name: "first_name", value: "Sue"}
            ]},
            {type: "question", name: "Hometown", value: { title: "Where did they grow up:", answer: "Grand Rapids"},
             children: [
               {type: "question", name: "currently.lives.in", value: { title: "Currently residing in:", answer: "Grand Rapids"}}
             ]}
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
    let leftProperties = oldProperties || []; //_.zip(oldProperties);
    let rightProperties = newProperties || []; //_.zip(newProperties);

    let left = 0; let right = 0;
    while (left < leftProperties.length || right < rightProperties.length) {
      let leftProperty = leftProperties[left];
      let rightProperty = rightProperties[right];

      if (left >= leftProperties.length) {
        result = result.concat( this.diffProperty(null, rightProperty) );
        right++;
      }
      else if (right >= rightProperties.length) {
        result = result.concat( this.diffProperty(leftProperty, null) );
        left++;
      }
      else if (leftProperties[left].type === rightProperties[right].type &&
          leftProperties[left].name === rightProperties[right].name) {
            // diffProperty
            result = result.concat( this.diffProperty(leftProperty, rightProperty) );
            left++;
            right++;
      } else if (this.wasRemoved(leftProperties[left], right, rightProperties)) {
        result = result.concat( this.diffProperty(leftProperty, null) );
        left++;

      } else if (this.wasInserted(rightProperties[right], left, leftProperties)) {
        result = result.concat( this.diffProperty(null, rightProperty) );
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
      newProperty = { name: oldProperty.name, type: oldProperty.type, value: "", children: [] };
    } else if(!oldProperty && newProperty){
      oldProperty = { name: newProperty.name, type: newProperty.type, value: "", children: [] };
    }
    let returnValue = [];

    let propertiesName = newProperty.name;

    if(oldProperty.type === "question" ) {
      let oldTitle = oldProperty.value.title || "";
      let newTitle = newProperty.value.title || "";
      let oldAnswer = oldProperty.value.answer || "";
      let newAnswer = newProperty.value.answer || "";

      let diff = JsDiff.diffWords(oldTitle, newTitle);
      diff = diff.concat( JsDiff.diffWords(oldAnswer, newAnswer));
      returnValue.push({ type: "propertyDiff", diffs: diff, name: newProperty.name });
      propertiesName = "";
    } else if(oldProperty.type === "text"){
      let diff = JsDiff.diffWords(oldProperty.value.toString(), newProperty.value.toString());
      returnValue.push({ type: "propertyDiff", diffs: diff, name: newProperty.name });
    } else if (oldProperty.type === "boolean") {
      let diff = JsDiff.diffWords(oldProperty.value.toString(), newProperty.value.toString());
      returnValue.push({ type: "propertyDiff", diffs: diff, name: newProperty.name });
    }

    if((oldProperty.children && oldProperty.children.length > 0) || (newProperty.children && newProperty.children.length > 0)){
      let diff = this.diffProperties(oldProperty.children, newProperty.children);
      returnValue.push({ type: "propertiesDiff", diffs: diff, name: propertiesName });
    }

    return returnValue;
  },

  diff: Ember.computed(function(){
    let results = this.diffProperties(this.old.properties, this.new.properties);
    return results;
  })
});
