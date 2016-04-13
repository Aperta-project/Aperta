import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('supporting-information-snapshot',
                   'Integration: supporting-information-snapshot-component',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var snapshot = function (){
  return {
    name: 'supporting-information-file',
    children: [
      {name: 'id', value: 'foo'},
      {name: 'title', value: 'squid'},
      {name: 'file', value: 'theFile.jpg'},
      {name: 'caption', value: "I'm the caption now"},
      {name: 'publishable', value: true},
      {name: 'striking_image', value: true},
    ]
  }
};

var template = hbs`{{supporting-information-snapshot
                     snapshot1=newSnapshot
                     snapshot2=oldSnapshot}}`;

test('no diff, no added or removed', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test('Diffs the title', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[1].value = 'Title here';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('squid', 'Title here');
});

test('Diffs the filename', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[2].value = 'newFile.jpg';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent('theFile.jpg', 'newFile.jpg');
});

test('Diffs the caption', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[3].value = 'look at me'

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent("I'm the caption now", 'look at me');
});

test('Diffs the publishable', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[4].value = false;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent("Yes", "No");
});

test('Diffs the striking image bool', function(assert){
  let secondSnaps = snapshot();
  secondSnaps.children[5].value = false;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', secondSnaps);

  this.render(template);

  assert.diffPresent("Yes", "No")
});
