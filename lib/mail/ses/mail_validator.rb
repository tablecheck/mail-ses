# frozen_string_literal: true

module Mail
  class SES
    # Validates a Mail::Message object before sending
    class MailValidator
      def initialize(mail)
        @mail = mail
      end

      def validate
        validate_class
        validate_delivery_params
        validate_attachments
      end

      private

      def validate_class
        return if @mail.is_a?(Mail::Message)

        raise ArgumentError.new('mail must be an instance of Mail::Message class')
      end

      def validate_delivery_params
        Mail::CheckDeliveryParams.check(@mail)
      end

      def validate_attachments
        return unless @mail.has_attachments? && @mail.text_part.nil? && @mail.html_part.nil?

        raise ArgumentError.new('Attachment provided without message body')
      end
    end
  end
end
