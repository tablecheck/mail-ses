module Mail

  # Mail delivery method handler for AWS SES
  class SES
    VERSION = File.read(File.join(File.dirname(__FILE__), '../../VERSION')).strip.freeze

    RAW_EMAIL_ATTRS = %i[source source_arn from_arn return_path_arn tags configuration_set_name].freeze

    attr_reader :client

    # Initializes the Mail::SES object.
    #
    # options - The Hash options (optional, default: {}):
    #   :mail_options    - (Hash) Default AWS options to set on each mail object.
    #   :error_handler   - (Proc<Error, Hash>) Handler for AWS API errors.
    #   :use_iam_profile - Shortcut to use AWS IAM instance profile.
    #   All other options are passed-thru to Aws::SES::Client.
    def initialize(options = {})
      @mail_options = options.delete(:mail_options) || {}
      @error_handler = options.delete(:error_handler)
      self.class.validate_error_handler(@error_handler)
      options = self.class.build_client_options(options)
      @client = Aws::SES::Client.new(options)
    end

    # Delivers a Mail object via SES.
    #
    # mail    - The Mail object to deliver (required).
    # options - The Hash options which override any defaults set in :mail_options
    #           in the initializer (optional, default: {}). Refer to
    #           Aws::SES::Client#send_raw_email
    def deliver!(mail, options = {})
      self.class.validate_mail(mail)
      options = @mail_options.merge(options || {})
      raw_email_options = self.class.build_raw_email_options(mail, options)
      begin
        response = client.send_raw_email(raw_email_options)
        mail.message_id = "#{response.to_h[:message_id]}@email.amazonses.com"
        response
      rescue => e
        @error_handler ? @error_handler.call(e, raw_email_options.dup) : raise(e)
      end
    end

    class << self
      def validate_error_handler(error_handler)
        raise ArgumentError.new(':error_handler must be a Proc') if error_handler && !error_handler.is_a?(Proc)
      end

      def validate_mail(mail)
        unless mail.is_a?(Mail::Message)
          raise ArgumentError.new('mail must be an instance of Mail::Message class')
        end

        Mail::CheckDeliveryParams.check(mail)

        if mail.has_attachments? && mail.text_part.nil? && mail.html_part.nil?
          raise ArgumentError.new('Attachment provided without message body')
        end
      end

      def build_client_options(options)
        options[:credentials] = Aws::InstanceProfileCredentials.new if options.delete(:use_iam_profile)
        options
      end

      def build_raw_email_options(message, options = {})
        output = slice_hash(options, *RAW_EMAIL_ATTRS)
        output[:source] ||= message.from.first
        output[:destinations] = [message.to, message.cc, message.bcc].flatten.compact
        output[:raw_message] = { data: Base64::encode64(message.to_s) }
        output
      end

      protected

      def slice_hash(hash, *keys)
        keys.each_with_object({}) { |k, h| h[k] = hash[k] if hash.has_key?(k) }
      end
    end
  end
end
