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

module ExportDelivery
  module DeliverySucceeded
    #
    # Sends an EventStream message, telling the browser to flash a success
    # message. Triggered when an ExportDelivery has successfully completed.
    #
    class FlashSuccessMessage < FlashMessageSubscriber
      def user
        export_delivery.user
      end

      def message_type
        'success'
      end

      def message
        "#{short_title} has been successfully exported"
      end

      private

      def export_delivery
        @event_data[:record]
      end

      def short_title
        title = export_delivery.paper.short_title || 'Manuscript'
        title.truncate(20)
      end
    end
  end
end
