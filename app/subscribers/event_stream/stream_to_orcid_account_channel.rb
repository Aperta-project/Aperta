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

class EventStream::StreamToOrcidAccountChannel < EventStreamSubscriber
  def channel
    private_channel_for(record.user)
  end

  def run
    # Here we're piggybacking off the users channel, but we're not excluding the
    # socket that initiated the action (as is default with the stock user
    # channel).  We don't want to exclude ourselves because the popup window
    # initiates the update action, and we want the main parent window to be
    # notified via websocket.
    TahiPusher::Channel
      .delay(queue: :eventstream, retry: false)
      .push(
        channel_name: channel,
        event_name: action,
        payload: payload
      )
  end
end
