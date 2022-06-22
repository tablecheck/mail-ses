# frozen_string_literal: true

require 'mail/ses/version'
require 'mail/ses/mail_validator'
require 'mail/ses/options_builder'

module Mail
  # Mail delivery method handler for AWS SES
  class SES
    RAW_EMAIL_ATTRS = %i[ from_email_address
                          from_email_address_identity_arn
                          feedback_forwarding_email_address
                          feedback_forwarding_email_address_identity_arn
                          email_tags
                          configuration_set_name ].freeze

    attr_accessor :settings
    attr_reader :client

    # Initializes the Mail::SES object.
    #
    # options - The Hash options (optional, default: {}):
    #   :mail_options    - (Hash) Default AWS options to set on each mail object.
    #   :error_handler   - (Proc<Error, Hash>) Handler for AWS API errors.
    #   :use_iam_profile - Shortcut to use AWS IAM instance profile.
    #   All other options are passed-thru to Aws::SESV2::Client.
    def initialize(options = {})
      @mail_options = options.delete(:mail_options) || {}

      @error_handler = options.delete(:error_handler)
      raise ArgumentError.new(':error_handler must be a Proc') if @error_handler && !@error_handler.is_a?(Proc)

      @settings = { return_response: options.delete(:return_response) }

      options[:credentials] = Aws::InstanceProfileCredentials.new if options.delete(:use_iam_profile)
      @client = Aws::SESV2::Client.new(options)
    end

    # Delivers a Mail object via SES.
    #
    # mail    - The Mail object to deliver (required).
    # options - The Hash options which override any defaults set in :mail_options
    #           in the initializer (optional, default: {}). Refer to
    #           Aws::SESV2::Client#send_email
    def deliver!(mail, options = {})
      MailValidator.new(mail).validate

      options = @mail_options.merge(options || {})
      send_options = OptionsBuilder.new(mail, options).build

      begin
        response = client.send_email(send_options)
        mail.message_id = "#{response.to_h[:message_id]}@email.amazonses.com"
        settings[:return_response] ? response : self
      rescue StandardError => e
        handle_error(e, send_options)
      end
    end

    private

    def handle_error(error, send_options)
      raise(error) unless @error_handler

      @error_handler.call(error, send_options.dup)
    end
  end
end
