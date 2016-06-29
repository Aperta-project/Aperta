import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('at-mentionable-textarea', 'Unit | Component | at mentionable textarea', {
  unit: true
});

const charmander = {
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokemon'
};

const bulbasaur = {
  username: 'bulbasaur',
  email: 'plant@oak.edu',
  name: 'Bulbasaur Pokemon'
};

const squirtle = {
  username: 'squirtle',
  email: 'water@oak.edu',
  name: 'Squirtle Pokemon (not Bulbasaur)'
};

let userList = [charmander, bulbasaur, squirtle];

test('#indexOfString', function(assert) {
  const component = this.subject({ atMentionableUsers: userList });
  assert.equal(component.indexOfString('Turtle', 'Tur'), 0);
  assert.equal(component.indexOfString('Turtle', 'tur'), 0);
  assert.equal(component.indexOfString('Turtle', 'urt'), 1);
  assert.equal(component.indexOfString('Turtle', 'uRt'), 1);
  assert.equal(component.indexOfString('Turtle', 'Human'), -1);
});

test('#containsString', function(assert) {
  const component = this.subject({ atMentionableUsers: userList });
  assert.ok(component.containsString('Turtle', 'Tur'));
  assert.ok(component.containsString('Turtle', 'tur'));
  assert.ok(component.containsString('Turtle', 'tle'));
  assert.ok(component.containsString('Turtle', ''));
  assert.notOk(component.containsString('Turtle', 'Human'));
});

test('#filter', function(assert) {
  const data = [charmander, bulbasaur, squirtle];
  const component = this.subject({ atMentionableUsers: data });
  const testCase = function(query, expected, msg) {
    assert.deepEqual(component.filter(query, data), expected, msg);
  };

  testCase('pokemon', data, 'matching on part of a full name');
  testCase('digimon', [], 'matching on something that does not match');
  testCase('', data, 'matching on empty string');
  testCase('oak.edu', data, 'matching on partial email');
  testCase('charmander', [charmander], 'filtering on username');
});

test('#sorter', function(assert){
  const data = [squirtle, bulbasaur];
  const component = this.subject({ atMentionableUsers: data });
  const testCase = function(query, expected, msg) {
    const sorted_items = component.sorter(query, data);
    const sorted_names = _.map(sorted_items, function(i) { return i.name; });
    const expected_names = _.map(expected, function(i) { return i.name; });
    assert.deepEqual(sorted_names, expected_names, msg);
  };

  testCase('Bulbasaur', [bulbasaur, squirtle],
    'it should sort by matches in the username first');
  testCase('oak.edu', [squirtle, bulbasaur],
    'it sorts by the index of the match in the user\'s concatenated details');
});

test('#highlighter', function(assert){
  const component = this.subject({ atMentionableUsers: userList });
  const query = 'char';
  const li = '<li><span class="at-who-name">Charmander Pokémon</span> <span class="at-who-username">@jcharmander</span> <span class="at-who-email">fire@oak.edu</span></li>';
  const expected = '<li><span class="at-who-name"><strong>Char</strong>mander Pokémon</span> <span class="at-who-username">@j<strong>char</strong>mander</span> <span class="at-who-email">fire@oak.edu</span></li>';
  assert.equal(component.highlighter(li, query), expected);
});
