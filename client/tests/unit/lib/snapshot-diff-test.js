import { module, test } from 'qunit';
import { compareJson } from 'tahi/lib/snapshot-diff';

module('Snapshot Diff');

test('comparison - competing interests', function (assert) {
  let json1 = {
    'name': 'competing-interests-task',
    'type': 'properties',
    'children': [
      {
        'name': 'competing_interests--has_competing_interests',
        'type': 'question',
        'value': {
          'id': 249,
          'title': "Do any authors of this manuscript have competing interests (as described in the \u003ca target='_blank' href='http://journals.plos.org/plosbiology/s/competing-interests'\u003ePLOS Policy on Declaration and Evaluation of Competing Interests\u003c/a\u003e)?",
          'answer_type': 'boolean',
          'answer': false,
          'attachments': []
        },
        'children': [
          {
            'name': 'competing_interests--statement',
            'type': 'question',
            'value': {
              'id': 250,
              'title': "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"",
              'answer_type': 'text',
              'answer': 'The authors have declared that no competing interests exist.',
              'attachments': []
            },
            'children': []
          }
        ]
      },
      {
        'name': 'id',
        'type': 'integer',
        'value': 79012
      }
    ]
  };
  let json2 = {
    'name': 'competing-interests-task',
    'type': 'properties',
    'children': [
      {
        'name': 'competing_interests--has_competing_interests',
        'type': 'question',
        'value': {
          'id': 249,
          'title': "Do any authors of this manuscript have competing interests (as described in the \u003ca target='_blank' href='http://journals.plos.org/plosbiology/s/competing-interests'\u003ePLOS Policy on Declaration and Evaluation of Competing Interests\u003c/a\u003e)?",
          'answer_type': 'boolean',
          'answer': false,
          'attachments': []
        },
        'children': [
          {
            'name': 'competing_interests--statement',
            'type': 'question',
            'value': {
              'id': 250,
              'title': "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"",
              'answer_type': 'html',
              'answer': 'The authors have declared that no competing interests exist.',
              'attachments': []
            },
            'children': []
          }
        ]
      },
      {
        'name': 'id',
        'type': 'integer',
        'value': 79012
      }
    ]
  };
  let result = compareJson(json1, json2);
  assert.equal(result, true);
});