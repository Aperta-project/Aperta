import Ember from 'ember';

export default Ember.Object.extend({
  old: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      { type: "properties", name: "authors", children: [
        { type: "properties", name: "author", children: [
            {type: "text", name: "first_name", value: "John"},
            {type: "text", name: "middle_name", value: "Paul"},
            {type: "text", name: "last_name", value: "Smith"},
            {type: "boolean", name: "true_or_false", value: false}
          ]
        },

        { type: "properties", name: "author", children: [
            {type: "text", name: "first_name", value: "Sally"},
            {type: "text", name: "last_name", value: "Doe"},
          ]
        }] // authors
      }
    ]  // properties
  }, // old

  new: {
    version: "4.5",
    date: "2015-09-01",

    properties: [
      { type: "properties", name: "authors", children: [
        { type: "properties", name: "author", children: [
            {type: "text", name: "first_name", value: "John"},
            {type: "text", name: "last_name", value: "George"},
            {type: "boolean", name: "true_or_false", value: true}
          ]
        },

        { type: "properties", name: "author", children: [
            {type: "text", name: "first_name", value: "Paul"},
            {type: "text", name: "last_name", value: "John"},
          ]
        }] // authors
      }
    ]  // properties

  }, // new

  diffProperties: function(oldProperties, newProperties){
    let result = [];
    let zippedProperties = _.zip(oldProperties, newProperties);

    _.each(zippedProperties, function(element){
      let oldProperty = element[0] || { type: "properties", children: [] };
      let newProperty = element[1] || { type: "properties", children: [] };

      if(oldProperty && newProperty) {
        if(oldProperty.type === "properties"){
          result.push( this.diffProperties(oldProperty.children, newProperty.children) );
        }
        else {
          result.push( this.diffProperty(oldProperty, newProperty) );
        }
      }
    }, this);

    return result;
  },



  diffProperty: function(oldProperty, newProperty) {
   if(oldProperty.type === "text"){
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
