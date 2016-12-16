import { moduleFor, test } from 'ember-qunit';

moduleFor('service:browser-detector', 'Unit | Service | browser detector', {
});

test('isIE11OrLess', function(assert) {
  assert.expect(7);
  let service = this.subject();

  function testIsIE11OrLess({ name, version, expect}) {
    service.set('name', name);
    service.set('version', version);
    if (expect) {
      assert.ok(service.get('isIE11OrLess'), `expect ${name} ${version} to be ${expect}`);
    } else {
      assert.notOk(service.get('isIE11OrLess'), `expect ${name} ${version} to be ${expect}`);
    }
  }

  testIsIE11OrLess({name: 'msie', version: '11.0', expect: true});
  testIsIE11OrLess({name: 'msie', version: '11.101.12', expect: true});
  testIsIE11OrLess({name: 'msie', version: '10.101.12', expect: true});
  testIsIE11OrLess({name: 'msie', version: '10', expect: true});
  testIsIE11OrLess({name: 'msie', version: '12.0', expect: false});
  testIsIE11OrLess({name: 'Chrome', version: '11.0', expect: false});
  testIsIE11OrLess({name: 'Firefox', version: '11.0', expect: false});
});
