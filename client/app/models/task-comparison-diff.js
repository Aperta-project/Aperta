import Ember from 'ember';

export default Ember.Object.extend({
  old: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      {"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"Another  Author"},{"name":"email","type":"text","value":"anoter@"},{"name":"title","type":"text","value":"Title"},{"name":"department","type":"text","value":"Department."},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":""},{"name":"secondary_affiliation","type":"text","value":""}]},{"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"Second P Author"},{"name":"email","type":"text","value":"second@email.com"},{"name":"title","type":"text","value":"Second Title"},{"name":"department","type":"text","value":"Second Department"},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":""},{"name":"secondary_affiliation","type":"text","value":""}]},{"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"First  Last"},{"name":"email","type":"text","value":"email@email.email"},{"name":"title","type":"text","value":"Title"},{"name":"department","type":"text","value":"Department"},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":"Institution"},{"name":"secondary_affiliation","type":"text","value":"Secondary Institution"}]},{"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"Third  Author"},{"name":"email","type":"text","value":"fourth@email.com"},{"name":"title","type":"text","value":"Title"},{"name":"department","type":"text","value":"Department"},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":""},{"name":"secondary_affiliation","type":"text","value":""}]}
    ]
  },

  new: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      {"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"Another  Author"},{"name":"email","type":"text","value":"anoter@"},{"name":"title","type":"text","value":"Title"},{"name":"department","type":"text","value":"Department."},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":""},{"name":"secondary_affiliation","type":"text","value":""}]},{"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"First  Last"},{"name":"email","type":"text","value":"email@email.email"},{"name":"title","type":"text","value":"Title"},{"name":"department","type":"text","value":"Department"},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":"Institution"},{"name":"secondary_affiliation","type":"text","value":"Secondary Institution"}]},{"name":"author","type":"properties","children":[{"name":"name","type":"text","value":"Third  Author"},{"name":"email","type":"text","value":"fourth@email.com"},{"name":"title","type":"text","value":"Title"},{"name":"department","type":"text","value":"Department"},{"name":"corresponding","type":"text","value":"false"},{"name":"deceased","type":"text","value":"false"},{"name":"affiliation","type":"text","value":""},{"name":"secondary_affiliation","type":"text","value":""}]}
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

    if(oldProperty.type === "properties" || newProperty.type === "properties") {
      if((oldProperty.children && oldProperty.children.length > 0) || (newProperty.children && newProperty.children.length > 0)){
        let diff = this.diffProperties(oldProperty.children, newProperty.children);
        returnValue.push({ type: "properties", diffs: diff, name: newProperty.name });
      }
    } else if(oldProperty.type === "question" || newProperty.type === "question") {
      let oldTitle = oldProperty.value.title || "";
      let newTitle = newProperty.value.title || "";
      let oldAnswer = oldProperty.value.answer || "";
      let newAnswer = newProperty.value.answer || "";
      let oldAttachment = oldProperty.value.attachment || "";
      let newAttachment = newProperty.value.attachment || "";

      let diffResults = [];

      diffResults.push(
        { type: "question-text", diffs: JsDiff.diffWords(oldTitle, newTitle), name: "title" }
      );

      if(oldAnswer.length > 0 || newAnswer.length > 0){
        diffResults.push({ type: "question-answer", diffs:  JsDiff.diffWords(oldAnswer, newAnswer), name: "value" });
      } else if(oldAttachment.length > 0 || newAttachment.length > 0){
        diffResults.push({ type: "question-attachment", diffs:  JsDiff.diffSentences(oldAttachment, newAttachment), name: "value" });
      }

      if((oldProperty.children && oldProperty.children.length > 0) || (newProperty.children && newProperty.children.length > 0)){
        let new_diff = this.diffProperties(oldProperty.children, newProperty.children);
        diffResults.push({ type: "properties", diffs: new_diff, name: newProperty.name });
      }

      returnValue.push({ type: "question", diffs: diffResults, name: newProperty.name });

    } else if(oldProperty.type === "text"){
      let diff = JsDiff.diffSentences(oldProperty.value.toString(), newProperty.value.toString());
      returnValue.push({ type: "text", diffs: diff, name: newProperty.name });

    } else if (oldProperty.type === "boolean") {
      let diff = JsDiff.diffWords(oldProperty.value.toString(), newProperty.value.toString());
      returnValue.push({ type: "boolean", diffs: diff, name: newProperty.name });
    }

    return returnValue;
  },

  diff: Ember.computed(function(){
    let results = this.diffProperties(this.old.properties, this.new.properties);
    return results;
  })
});
