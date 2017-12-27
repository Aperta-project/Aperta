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
