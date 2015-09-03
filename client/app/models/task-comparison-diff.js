import Ember from 'ember';

export default Ember.Object.extend({
  old: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      { type: "properties", name: "publishing-related-questions", children: [
        { type: "question", name: "question-1", value:
          {
            title: "Have the results, data, or figures in this manuscript been published elsewhere? Are they under consideration for publication elsewhere?",
            answer: "Yes"
          },
          children: [
            { type: "question", name: "question-1a",
              value:  {
                title: "Results, data or figures:",
                answer: "Figure 2: Abico in singularis ut delenit sed mara volutpat os os dignissim. Illum luptatum quod capio augue ex abdo imputo probo in appellatio. Tincid-unt abbas velit quis convention. Luptatum distineo virtus feugait. Utrum neque decet. Et melior a ratis abdo cui nisl."
              }
            },
            { type: "text", name: "attachment-file-name", value: "white-rodgers-thermostat_1F80.pdf" },
            { type: "text", name: "attachment-title", value: "Singularis ut Delenit" },
            { type: "text", name: "attachment-caption", value: "Illum luptatum quod capio augue ex abdo imputo probo in appellatio. Sed utrum duis vel refoveo interdico facilisi zelus. Utrum neque decet." },
          ]
        },

        { type: "question", name: "question-2", value:
          {
            title: "Is this manuscript being submitted in conjunction with another submission?",
            answer: "Yes"
          },
          children: [
            { type: "question", name: "question-2a",
              value:  {
                title: "Title",
                answer: "Miocene Odobenids from Mars"
              }
            },
            { type: "question", name: "question-2b",
              value:  {
                title: "Corresponding Author",
                answer: "Sir Walter W. Alerus"
              }
            }
          ]
        },

        { type: "question", name: "question-3", value:
          {
            title: "Please indicate whether you have had any of the following previous interactions about this manuscript. Check all that apply.",
            answer: ""
          },
          children: [
            { type: "properties", name: "Responses:", children: [
              { type: "question", name: "question-3b",
                value:  {
                  title: "One or more authors (including myself) curently serve, or have previously served, as an Academic Editor or Guest Editor for this journal.",
                  answer: ""
                }
              },
            ]
          }]
        },

        { type: "question", name: "question-4", value:
          {
            title: "If your submission is intendd for a PLOS Collection, enter the name of the collection in the box below. Please also ensure the name of the collection is included in your cover letter.",
            answer: ""
          },
          children: [
            { type: "question", name: "question-4a",
              value:  {
                title: "Name of PLOS Collection",
                answer: "Oceanic Critter Collection"
              }
            },
          ]
        },

        { type: "question", name: "question-5", value:
          {
            title: "Are you or any of the contributing authors an employee of the United States Government",
            answer: "Yes"
          },
        }
      ]
    }
    ]
  },

  new: {
    version: "4.4",
    date: "2015-08-01",

    properties: [
      { type: "properties", name: "publishing-related-questions", children: [
        { type: "question", name: "question-1", value:
          {
            title: "Have the results, data, or figures in this manuscript been published elsewhere? Are they under consideration for publication elsewhere?",
            answer: "Yes"
          },
          children: [
            { type: "question", name: "question-1a",
              value:  {
                title: "Results, data or figures:",
                answer: "Figure 2: Abico in singularis ut delenit sed mara volutpat os os dignissim. Illum luptatum quod capio augue ex abdo imputo probo in appellatio. Tincid-unt abbas velit quis convention. Luptatum distineo virtus feugait. Utrum neque decet. Et melior a ratis abdo cui nisl."
              }
            },
            { type: "text", name: "attachment-file-name", value: "riceCooker-man.pdf" },
            { type: "text", name: "attachment-title", value: "Singularis ut Delenit" },
            { type: "text", name: "attachment-caption", value: "Illum luptatum quod capio augue ex abdo imputo. Sed utrum duis vel refoveo interdico facilisi zelus. Tincidunt abbas velit quis conventio. Luptatum distineo virtus feugait. Utrum neque decet." },
          ]
        },

        { type: "question", name: "question-2", value:
          {
            title: "Is this manuscript being submitted in conjunction with another submission?",
            answer: "No"
          },
          children: []
        },

        { type: "question", name: "question-3", value:
          {
            title: "Please indicate whether you have had any of the following previous interactions about this manuscript. Check all that apply.",
            answer: ""
          },
          children: [
            { type: "properties", name: "Responses:", children: [
              { type: "question", name: "question-3a",
                value:  {
                  title: "I submitted a presubmission inquiry for this manuscript",
                  answer: "2094. Sarah Tusk"
                }
              },
              { type: "question", name: "question-3b",
                value:  {
                  title: "One or more authors (including myself) curently serve, or have previously served, as an Academic Editor or Guest Editor for this journal.",
                  answer: ""
                }
              },
            ]}
          ]
        },

        { type: "question", name: "question-4", value:
          {
            title: "If your submission is intendd for a PLOS Collection, enter the name of the collection in the box below. Please also ensure the name of the collection is included in your cover letter.",
            answer: ""
          },
          children: [
            { type: "question", name: "question-4a",
              value:  {
                title: "Name of PLOS Collection",
                answer: "Oceanic Critter Collection"
              }
            },
          ]
        },

        { type: "question", name: "question-5", value:
          {
            title: "Are you or any of the contributing authors an employee of the United States Government",
            answer: "Yes"
          },
        }
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

    if(oldProperty.type === "properties" || newProperty.type === "properties") {
      if((oldProperty.children && oldProperty.children.length > 0) || (newProperty.children && newProperty.children.length > 0)){
        let diff = this.diffProperties(oldProperty.children, newProperty.children);
        returnValue.push({ type: "propertiesDiff", diffs: diff, name: newProperty.name });
      }
    } else if(oldProperty.type === "question" || newProperty.type === "question") {
      let oldTitle = oldProperty.value.title || "";
      let newTitle = newProperty.value.title || "";
      let oldAnswer = oldProperty.value.answer || "";
      let newAnswer = newProperty.value.answer || "";

      let diffResults = [];

      diffResults.push(
        { type: "question-text", diffs: JsDiff.diffWords(oldTitle, newTitle), name: "title" }
      );
      diffResults.push(
        { type: "question-answer", diffs:  JsDiff.diffWords(oldAnswer, newAnswer), name: "value" }
      );

      if((oldProperty.children && oldProperty.children.length > 0) || (newProperty.children && newProperty.children.length > 0)){
        let new_diff = this.diffProperties(oldProperty.children, newProperty.children);
        diffResults.push({ type: "propertiesDiff", diffs: new_diff, name: newProperty.name });
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
