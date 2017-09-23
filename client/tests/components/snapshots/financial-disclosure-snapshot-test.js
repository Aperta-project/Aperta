import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('nested-snapshot',
  'Integration | Component | Financial disclosure snapshot',
  {integration: true, beforeEach: registerDiffAssertions});

var snapshot1 = function() {
  return {
    name: 'financial-disclosure-task',
    type: 'properties',
    children: [
      {
        name: 'financial_disclosures--author_received_funding',
        type: 'question',
        value: {
          title: 'author funding',
          answer_type: 'boolean',
          answer: true
        }
      },
      {
        name: 'funder',
        type: 'properties',
        children: [
          {
            name: 'funder--had_influence',
            type: 'question',
            value: {
              title: 'had influence',
              answer_type: 'boolean',
              answer: false
            },
            children: [
              {
                name: 'funder--had_influence--role_description',
                type: 'question',
                value: {
                  title: 'role',
                  answer_type: 'text',
                  answer: ''
                }
              }
            ]
          },
          { name: 'name', type: 'text', value: 'Jedi Academy' },
          { name: 'grant_number', type: 'text', value: '12345' },
          { name: 'website', type: 'text', value: 'jedi.edu' },
          { name: 'additional_comments', type: 'text', value: 'Additional comments go here.' }
        ]
      }
    ]
  };
};

var snapshot2 = function() {
  return {
    name: 'financial-disclosure-task',
    type: 'properties',
    children: [
      {
        name: 'financial_disclosures--author_received_funding',
        type: 'question',
        value: {
          title: 'author funding',
          answer_type: 'boolean',
          answer: true
        }
      },
      {
        name: 'funder',
        type: 'properties',
        children: [
          {
            name: 'funder--had_influence',
            type: 'question',
            value: {
              title: 'had influence',
              answer_type: 'boolean',
              answer: true
            },
            children: [
              {
                name: 'funder--had_influence--role_description',
                type: 'question',
                value: {
                  title: 'role',
                  answer_type: 'text',
                  answer: 'Recruited participants'
                }
              }
            ]
          },
          { name: 'name', type: 'text', value: 'Jedi Academy' },
          { name: 'grant_number', type: 'text', value: '12345' },
          { name: 'website', type: 'text', value: 'jedi.edu' },
          { name: 'additional_comments', type: 'text', value: 'Additional comments go here.' }
        ]
      }
    ]
  };
};

var template = hbs`{{nested-snapshot snapshot1=viewing snapshot2=comparison}}`;

test('no diff, no added or removed', function(assert){
  this.set('viewing', snapshot1());
  this.set('comparison', snapshot1());

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test('Has added and removed diff', function(assert){
  this.set('viewing', snapshot2());
  this.set('comparison', snapshot1());

  this.render(template);
  assert.equal(this.$('.added').length, 2, 'Wrong number of added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Wrong number of removed diff spans');
  assert.textPresent('.added', 'Recruited participants');
  assert.textPresent('.added', 'Yes');
  assert.textPresent('.removed', 'No');
});
