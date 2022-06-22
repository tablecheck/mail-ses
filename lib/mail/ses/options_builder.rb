# frozen_string_literal: true

module Mail
  class SES
    # Builds options for Aws::SESV2::Client#send_email
    class OptionsBuilder
      def initialize(message, options = {})
        @message = message
        @options = options
      end

      def build
        message_options.merge(ses_options)
      end

      private

      def ses_options
        slice_hash(@options, *RAW_EMAIL_ATTRS)
      end

      def message_options
        {
          from_email_address: @message.from&.first,
          destination: {
            to_addresses: Array(@message.to).compact,
            cc_addresses: Array(@message.cc).compact,
            bcc_addresses: Array(@message.bcc).compact
          },
          content: { raw: { data: @message.to_s } }
        }.compact
      end

      def slice_hash(hash, *keys)
        keys.each_with_object({}) { |k, h| h[k] = hash[k] if hash.key?(k) }
      end
    end
  end
end
