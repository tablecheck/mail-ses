# frozen_string_literal: true

module Mail
  class SES
    # Builds options for Aws::SESV2::Client#send_email
    class OptionsBuilder
      # message - The Mail::Message object to be sent.
      # options - The Hash options which override any defaults
      #           from the message.
      def initialize(message, options = {})
        @message = message
        @options = options
      end

      # Returns the options for Aws::SESV2::Client#send_email.
      def build
        message_options.merge(ses_options)
      end

      private

      def ses_options
        slice_hash(@options, *RAW_EMAIL_ATTRS)
      end

      def message_options
        {
          from_email_address: extract_value(:from)&.first,
          reply_to_addresses: extract_value(:reply_to),
          destination: {
            to_addresses: extract_value(:to) || [],
            cc_addresses: extract_value(:cc) || [],
            bcc_addresses: extract_value(:bcc) || []
          },
          content: { raw: { data: @message.to_s } }
        }.compact
      end

      def slice_hash(hash, *keys)
        keys.each_with_object({}) { |k, h| h[k] = hash[k] if hash.key?(k) }
      end

      def extract_value(key)
        @message.header[key]&.formatted
      end
    end
  end
end
