module ApexDelivery
  module DeliverySucceeded
    #
    # Sends an EventStream message, telling the browser to flash a success
    # message. Triggered when an ApexDelivery has successfully completed.
    #
    class FlashSuccessMessage < FlashMessageSubscriber
      def user
        apex_delivery.user
      end

      def message_type
        'success'
      end

      def message
        "#{short_title} has been successfully uploaded to Apex"
      end

      private

      def apex_delivery
        @event_data[:record]
      end

      def short_title
        title = apex_delivery.paper.short_title || 'Manuscript'
        title.truncate(20)
      end
    end
  end
end
