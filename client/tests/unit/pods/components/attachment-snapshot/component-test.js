import { moduleFor, test} from 'ember-qunit';

moduleFor(
  'component:attachment-snapshot',
  'Unit | Component | attachment snapshot'
);

testFileHashes(null, null, false);
testFileHashes(null, 'foo', true);
testFileHashes('foo', null, true);
testFileHashes('foo', 'foo', false);
testFileHashes('foo', 'bar', true);

function testFileHashes(hash1, hash2, boolean) {
  test(`it checks for hash differences given ${hash1} and ${hash2}`, function(assert){
    let component = this.subject({
      attachment1: {fileHash: hash1},
      attachment2: {fileHash: hash2}
    });

    assert.equal(
      component.get('fileHashChanged'),
      boolean,
      'returns ${boolean}'
    );
  });
}

