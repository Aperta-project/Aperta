import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('nested-snapshot',
  'Integration | Component | nested snapshot | custom card',
  {integration: true,
    beforeEach: function() {
      registerDiffAssertions();
    }});

// The following insanely long object is a representation of two Competing Interests snapshots as they
// were serialized to Ember during development of APERTA-10097. If diffing is working as intended, only
// a subset of the children here will be rendered, resulting in only two 'snapshot-question' divs.
var snapshots = function() {
  return [
    {
      id: 107,
      source_id: 226,
      source_type: 'Task',
      major_version: 0,
      minor_version: 0,
      contents: {
        name: 'custom-card-task',
        type: 'properties',
        children: [
          {
            name: 'competing_interests--has_competing_interests',
            type: 'question',
            value: {
              id: 256,
              title: '<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.<\/p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http:\/\/journals.plos.org\/plosbiology\/s\/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests<\/a>)?<\/div><\/li>',
              answer_type: 'text',
              answer: 'f',
              attachments: [

              ]
            },
            children: [
              {
                name: null,
                type: 'question',
                value: {
                  id: 257,
                  title: null,
                  answer_type: null,
                  answer: null,
                  attachments: [

                  ]
                },
                children: [
                  {
                    name: null,
                    type: 'question',
                    value: {
                      id: 258,
                      title: null,
                      answer_type: null,
                      answer: null,
                      attachments: [

                      ]
                    },
                    children: [
                      {
                        name: 'competing_interests--statement',
                        type: 'question',
                        value: {
                          id: 259,
                          title: 'Please provide details about any and all competing interests in the box below. Your response should begin with this statement: "I have read the journal\'s policy and the authors of this manuscript have the following competing interests.',
                          answer_type: 'html',
                          answer: null,
                          attachments: [

                          ]
                        },
                        children: [

                        ]
                      }
                    ]
                  }
                ]
              },
              {
                name: null,
                type: 'question',
                value: {
                  id: 260,
                  title: null,
                  answer_type: null,
                  answer: null,
                  attachments: [

                  ]
                },
                children: [
                  {
                    name: null,
                    type: 'question',
                    value: {
                      id: 261,
                      title: null,
                      answer_type: null,
                      answer: null,
                      attachments: [

                      ]
                    },
                    children: [
                      {
                        name: null,
                        type: 'question',
                        value: {
                          id: 262,
                          title: 'Your competing interests statement will appear as: "The authors have declared that no competing interests exist."\nPlease note that if your manuscript is accepted, this statement will be published.',
                          answer_type: null,
                          answer: null,
                          attachments: [

                          ]
                        },
                        children: [

                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            name: 'id',
            type: 'integer',
            value: 226
          }
        ]
      },
      created_at: '2017-08-15T13:58:25.502Z'
    },
    {
      id: 109,
      source_id: 226,
      source_type: 'Task',
      major_version: 1,
      minor_version: 0,
      contents: {
        name: 'custom-card-task',
        type: 'properties',
        children: [
          {
            name: 'competing_interests--has_competing_interests',
            type: 'question',
            value: {
              id: 256,
              title: '<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.<\/p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http:\/\/journals.plos.org\/plosbiology\/s\/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests<\/a>)?<\/div><\/li>',
              answer_type: 'text',
              answer: 't',
              attachments: [

              ]
            },
            children: [
              {
                name: null,
                type: 'question',
                value: {
                  id: 257,
                  title: null,
                  answer_type: null,
                  answer: null,
                  attachments: [

                  ]
                },
                children: [
                  {
                    name: null,
                    type: 'question',
                    value: {
                      id: 258,
                      title: null,
                      answer_type: null,
                      answer: null,
                      attachments: [

                      ]
                    },
                    children: [
                      {
                        name: 'competing_interests--statement',
                        type: 'question',
                        value: {
                          id: 259,
                          title: 'Please provide details about any and all competing interests in the box below. Your response should begin with this statement: "I have read the journal\'s policy and the authors of this manuscript have the following competing interests.',
                          answer_type: 'html',
                          answer: '<p>I should point out that\u00a0I\'m totally a shill for corporate interests, and all my studies should be considered suspect.<\/p>',
                          attachments: [

                          ]
                        },
                        children: [

                        ]
                      }
                    ]
                  }
                ]
              },
              {
                name: null,
                type: 'question',
                value: {
                  id: 260,
                  title: null,
                  answer_type: null,
                  answer: null,
                  attachments: [

                  ]
                },
                children: [
                  {
                    name: null,
                    type: 'question',
                    value: {
                      id: 261,
                      title: null,
                      answer_type: null,
                      answer: null,
                      attachments: [

                      ]
                    },
                    children: [
                      {
                        name: null,
                        type: 'question',
                        value: {
                          id: 262,
                          title: 'Your competing interests statement will appear as: "The authors have declared that no competing interests exist."\nPlease note that if your manuscript is accepted, this statement will be published.',
                          answer_type: null,
                          answer: null,
                          attachments: [

                          ]
                        },
                        children: [

                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            name: 'id',
            type: 'integer',
            value: 226
          }
        ]
      },
      created_at: '2017-08-15T14:01:45.708Z'
    },
    {
      id: -226,
      source_id: 226,
      source_type: 'Task',
      major_version: null,
      minor_version: null,
      contents: {
        name: 'custom-card-task',
        type: 'properties',
        children: [
          {
            name: 'competing_interests--has_competing_interests',
            type: 'question',
            value: {
              id: 256,
              title: '<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.<\/p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http:\/\/journals.plos.org\/plosbiology\/s\/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests<\/a>)?<\/div><\/li>',
              answer_type: 'text',
              answer: 'true',
              attachments: [

              ]
            },
            children: [
              {
                name: null,
                type: 'question',
                value: {
                  id: 257,
                  title: null,
                  answer_type: null,
                  answer: null,
                  attachments: [

                  ]
                },
                children: [
                  {
                    name: null,
                    type: 'question',
                    value: {
                      id: 258,
                      title: null,
                      answer_type: null,
                      answer: null,
                      attachments: [

                      ]
                    },
                    children: [
                      {
                        name: 'competing_interests--statement',
                        type: 'question',
                        value: {
                          id: 259,
                          title: 'Please provide details about any and all competing interests in the box below. Your response should begin with this statement: "I have read the journal\'s policy and the authors of this manuscript have the following competing interests.',
                          answer_type: 'html',
                          answer: '<p>I should point out that\u00a0I\'m totally a shill for corporate interests, and all my studies should be considered suspect.<\/p>',
                          attachments: [

                          ]
                        },
                        children: [

                        ]
                      }
                    ]
                  }
                ]
              },
              {
                name: null,
                type: 'question',
                value: {
                  id: 260,
                  title: null,
                  answer_type: null,
                  answer: null,
                  attachments: [

                  ]
                },
                children: [
                  {
                    name: null,
                    type: 'question',
                    value: {
                      id: 261,
                      title: null,
                      answer_type: null,
                      answer: null,
                      attachments: [

                      ]
                    },
                    children: [
                      {
                        name: null,
                        type: 'question',
                        value: {
                          id: 262,
                          title: 'Your competing interests statement will appear as: "The authors have declared that no competing interests exist."\nPlease note that if your manuscript is accepted, this statement will be published.',
                          answer_type: null,
                          answer: null,
                          attachments: [

                          ]
                        },
                        children: [

                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            name: 'id',
            type: 'integer',
            value: 226
          }
        ]
      },
      created_at: null
    }
  ];
};

var template = hbs`{{nested-snapshot
                     snapshot1=newSnapshot
                     snapshot2=oldSnapshot}}`;

test('Only render appropriate questions', function(assert){
  let snapshotArray = snapshots();
  this.set('oldSnapshot', snapshotArray[0].contents);
  this.set('newSnapshot', snapshotArray[1].contents);

  this.render(template);
  assert.equal(this.$('.snapshot-question').length, 2, 'Questions with no answer type were not rendered');
});

