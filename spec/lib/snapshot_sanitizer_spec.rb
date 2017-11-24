require 'rails_helper'
require 'snapshot_sanitizer'

describe 'SnapshotSanitizer' do
  it 'sanitizes a snapshot - non comform data types - integer' do
    snapshot = 123
    expected_snapshot = 123
    expect(SnapshotSanitizer.sanitize(snapshot)).to eq expected_snapshot
  end

  it 'sanitizes a snapshot - non comform data types - string' do
    snapshot = 'hello world'
    expected_snapshot = 'hello world'
    expect(SnapshotSanitizer.sanitize(snapshot)).to eq expected_snapshot
  end

  it 'sanitizes a snapshot - non comform data types - empty array' do
    snapshot = []
    expected_snapshot = []
    expect(SnapshotSanitizer.sanitize(snapshot)).to eq expected_snapshot
  end

  it 'sanitizes a snapshot - deletes all ID properties' do
    snapshot = { 'id': 123, 'name': 'task1' }
    expected_snapshot = { 'name': 'task1' }
    expect(SnapshotSanitizer.sanitize(snapshot)).to eq expected_snapshot
  end

  it 'sanitizes a snapshot - deletes all ID properties (nested)' do
    snapshot = { 'id': 123, 'name': 'task1', 'children': { 'id': 123, 'name': 'task2' } }
    expected_snapshot = { 'name': 'task1', 'children': { 'name': 'task2' } }
    expect(SnapshotSanitizer.sanitize(snapshot)).to eq expected_snapshot
  end
end
