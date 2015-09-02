import Ember from 'ember';

export default Ember.Object.extend({
  old: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      { type: "properties", name: "authors", children: [
        { type: "properties", name: "author", children: [
          { type: "text", name: "name", value: "Diana Smith"},
          { type: "text", name: "email", value: "dsmith@example.com"},
          { type: "text", name: "another.field", value: "Chupa chups pastry topping chocolate cake cholocate cake."},
          { type: "text", name: "institution", value: "Arizona State Polytechnic Campus"}
        ]},
        { type: "properties", name: "author", children: [
          { type: "text", name: "name", value: "Jane Goodall"},
          { type: "text", name: "email", value: "jane.goodall@example.com"},
          { type: "text", name: "another.field", value: "World's Foremost Authority on Chimpanzees - Primatology"},
          { type: "text", name: "institution", value: "Arizona State Polytechnic Campus"}
        ]}
      ]}
    ]
  },

  new: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      { type: "properties", name: "authors", children: [
        { type: "properties", name: "author", children: [
          { type: "text", name: "name", value: "Diana Smith"},
          { type: "text", name: "email", value: "dianasmith@gmail.com"},
          { type: "text", name: "another.field", value: "Chupa chups pastry topping chocolate cake cholocate cake."},
          { type: "text", name: "institution", value: "Arizona State Polytechnic Campus"}
        ]},
        { type: "properties", name: "author", children: [
          { type: "text", name: "name", value: "Holly Something"},
          { type: "text", name: "email", value: "hollysomething@example.come"},
          { type: "text", name: "another.field", value: "Another description if required"},
          { type: "text", name: "institution", value: "Washington State-Polytechnic Campus"}
        ]}
      ]}
    ]
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

    if(oldProperty.type === "question" ) {
      let oldTitle = oldProperty.value.title || "";
      let newTitle = newProperty.value.title || "";
      let oldAnswer = oldProperty.value.answer || "";
      let newAnswer = newProperty.value.answer || "";

      let diff = JsDiff.diffWords(oldTitle, newTitle);
      diff = diff.concat( JsDiff.diffWords(oldAnswer, newAnswer));
      returnValue.push({ type: "propertyDiff", diffs: diff, name: newProperty.name });
    } else if(oldProperty.type === "text"){
      let diff = JsDiff.diffSentences(oldProperty.value.toString(), newProperty.value.toString());
      returnValue.push({ type: "propertyDiff", diffs: diff, name: newProperty.name });
    } else if (oldProperty.type === "boolean") {
      let diff = JsDiff.diffWords(oldProperty.value.toString(), newProperty.value.toString());
      returnValue.push({ type: "propertyDiff", diffs: diff, name: newProperty.name });
    }

    if((oldProperty.children && oldProperty.children.length > 0) || (newProperty.children && newProperty.children.length > 0)){
      let diff = this.diffProperties(oldProperty.children, newProperty.children);
      returnValue.push({ type: "propertiesDiff", diffs: diff, name: newProperty.name });
    }

    return returnValue;
  },

  diff: Ember.computed(function(){
    let results = this.diffProperties(this.old.properties, this.new.properties);
    return results;
  })
});
