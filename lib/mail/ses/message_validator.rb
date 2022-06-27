# frozen_string_literal: true

module Mail
  class SES
    # Validates a Mail::Message object before sending
    class MessageValidator
      # message - The Mail::Message object to be validated.
      def initialize(message)
        @message = message
      end

      # Validate the message.
      def validate
        validate_class
        validate_delivery_params
        validate_attachments
      end

      private

      def validate_class
        return if @message.is_a?(Mail::Message)

        raise ArgumentError.new('mail must be an instance of Mail::Message class')
      end

      def validate_delivery_params
        if defined?(Mail::CheckDeliveryParams) # mail gem < 2.7.0
          Mail::CheckDeliveryParams.check(@message)
        elsif defined?(Mail::SmtpEnvelope) # mail gem >= 2.8.0
          Mail::SmtpEnvelope.new(@message)
        end
      end

      def validate_attachments
        return unless @message.has_attachments? && @message.text_part.nil? && @message.html_part.nil?

        raise ArgumentError.new('Attachment provided without message body')
      end
    end
  end
end
