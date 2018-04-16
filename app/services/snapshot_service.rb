# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class SnapshotService
  def self.configure(&blk)
    registry.instance_eval(&blk)
  end

  def self.registry
    @registry ||= Registry.new
  end

  def self.snapshot_paper!(paper, registry = SnapshotService.registry)
    snapshot_service = new(paper, registry)
    snapshot_service.snapshot!(paper.snapshottable_things)
  end

  def initialize(paper, registry = SnapshotService.registry)
    @paper = paper
    @registry = registry
  end

  def snapshot!(*things_to_snapshot)
    snapshots = preview(*things_to_snapshot)
    snapshots.each do |snapshot|
      snapshot.major_version = @paper.major_version
      snapshot.minor_version = @paper.minor_version
      snapshot.save!
    end
  end

  def preview(*things_to_snapshot)
    things_to_snapshot.flatten.map do |thing|
      serializer_klass = @registry.serializer_for(thing)
      json = serializer_klass.new(thing).as_json
      Snapshot.new(
        source: thing,
        contents: json,
        paper: @paper,
        major_version: nil,
        minor_version: nil)
    end
  end
end
