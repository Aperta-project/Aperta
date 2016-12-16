import { moduleFor, test } from 'ember-qunit';

moduleFor('service:browser-detector', 'Unit | Service | browser detector', {
});

test('isIE11OrLess', function(assert) {
  assert.expect(7);
  let service = this.subject();

  function testIsIE11OrLess({ msie, version, expect}) {
    service.set('msie', msie);
    service.set('version', version);
    if (expect) {
      assert.ok(service.get('isIE11OrLess'), `expect msie:${msie} ${version} to be ${expect}`);
    } else {
      assert.notOk(service.get('isIE11OrLess'), `expect msie:${msie} ${version} to be ${expect}`);
    }
  }

  testIsIE11OrLess({msie: true, version: '11.0', expect: true});
  testIsIE11OrLess({msie: true, version: '11.101.12', expect: true});
  testIsIE11OrLess({msie: true, version: '10.101.12', expect: true});
  testIsIE11OrLess({msie: true, version: '10', expect: true});
  testIsIE11OrLess({msie: true, version: '12.0', expect: false});
  testIsIE11OrLess({msie: false, version: '11.0', expect: false});
  testIsIE11OrLess({msie: false, version: '11.0', expect: false});
});
