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

module EventStreamMatchers
  RSpec::Matchers.define :receive_push do |expected|
    # the payload should contain this key at the root of the json object
    object = expected[:serialize]

    # the payload will be sent _down_ this channel
    channel = expected[:down]
    # the crud action that corresponds to the event (used by Ember)
    action = expected[:on]

    match do |actual|
      expect(actual).to receive(:push) do |args|
        expect(args[:channel_name]).to match(channel_name(channel))
        expect(args[:event_name]).to eq(action)

        if object
          expect(args[:payload][:id]).to be(object.id)
        else
          expect(args[:payload]).to match(expected[:payload])
        end
      end
    end

    # Not sure if this is what we actually expece, but at least it generally works
    match_when_negated do |actual|
      expect(actual).to_not receive(:push)
      true
    end

    def channel_name(channel_scope)
      if channel_scope == 'system'
        /^system$/
      elsif channel_scope == 'admin'
        /^private-#{channel_scope}/
      else
        /^private-#{channel_scope}@.*/
      end
    end
  end

end
