# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mail::SES do
  let(:ses_options) { { stub_responses: true } }

  let(:ses) do
    described_class.new(ses_options)
  end

  let(:to) { %w[to1@def.com to2@xyz.com] }
  let(:cc) { %w[cc1@xyz.com cc2@def.com] }
  let(:bcc) { %w[bcc1@abc.com bcc2@def.com] }

  let(:mail) do
    Mail.new do
      from 'from@abc.com'
      to %w[to1@def.com to2@xyz.com]
      cc %w[cc1@xyz.com cc2@def.com]
      bcc %w[bcc1@abc.com bcc2@def.com]
      body 'This is the body'
    end
  end

  describe '::VERSION' do
    it { expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+/) }
  end

  describe '#settings' do
    it do
      expect(ses).to respond_to(:settings, :settings=)
      expect(ses.settings).to eq(return_response: nil)
    end
  end

  describe '#initialize' do
    it 'accepts valid :error_handler' do
      expect(described_class.new(ses_options)).to be_a(Mail::SES)
    end

    it 'accepts valid :error_handler' do
      expect(described_class.new(ses_options.merge(error_handler: ->(a, b) {}))).to be_a(Mail::SES)
    end

    it 'rejects invalid :error_handler' do
      expect { described_class.new(ses_options.merge(error_handler: 'foobar')) }.to raise_error(ArgumentError, ':error_handler must be a Proc')
    end

    it 'handles :use_iam_profile option' do
      allow_any_instance_of(Aws::InstanceProfileCredentials).to receive(:get_credentials).and_return('{}')
      ses = described_class.new(ses_options.merge(use_iam_profile: true))
      expect(ses.client.config.credentials).to be_a(Aws::InstanceProfileCredentials)
    end

    it 'passes through options to AWS' do
      ses = described_class.new(ses_options.merge(log_level: :debug, retry_limit: 5))
      expect(ses.client.config.log_level).to eq :debug
      expect(ses.client.config.retry_limit).to eq 5
    end
  end

  describe '#deliver!' do
    it 'validates that mail is a Mail' do
      expect { ses.deliver!(foo: :bar) }.to raise_error(ArgumentError, 'mail must be an instance of Mail::Message class')
    end

    it 'validates integrity of Mail' do
      expect { ses.deliver!(Mail.new) }.to raise_error(ArgumentError, 'SMTP From address may not be blank: nil')
      expect { ses.deliver!(Mail.new { from 'foo@bar.com' }) }.to raise_error(ArgumentError, 'SMTP To address may not be blank: []')
    end

    it 'validates attachment without body' do
      mail.body = nil
      mail.add_file __FILE__
      expect { ses.deliver!(mail) }.to raise_error(ArgumentError, 'Attachment provided without message body')
    end

    context 'when options set' do
      before { allow(mail).to receive(:to_s).and_return('Fixed message body') }
      let(:ses_options) { { stub_responses: true, mail_options: { from_email_address: 'foo@bar.com', from_email_address_identity_arn: 'sa1' } } }

      let(:exp) do
        {
          from_email_address: 'foo@bar.com',
          from_email_address_identity_arn: 'sa2',
          destination: {
            to_addresses: to,
            cc_addresses: cc,
            bcc_addresses: bcc,
          },
          content: {
            raw: {
              data: 'Fixed message body'
            }
          }
        }
      end

      it 'allows pass-thru and override of default options' do
        expect(ses.client).to receive(:send_email).with(exp)
        ses.deliver!(mail, from_email_address_identity_arn: 'sa2')
      end
    end

    it 'sets mail.message_id' do
      ses.deliver!(mail)
      expect(mail.message_id).to eq('OutboundMessageId@email.amazonses.com')
    end

    it 'returns the AWS response' do
      expect(ses.deliver!(mail)).to be_a(Mail::SES)
    end

    context 'when :return_response set' do
      let(:ses_options) { { stub_responses: true, return_response: true } }

      it 'returns the AWS response' do
        expect(ses.deliver!(mail)).to be_a(Seahorse::Client::Response)
      end
    end

    context 'error handling' do
      before { allow_any_instance_of(Aws::SESV2::Client).to receive(:send_email).and_raise(RuntimeError.new('test')) }

      context 'when :error_handler not set' do
        it 'raises the error' do
          expect { ses.deliver!(mail) }.to raise_error(RuntimeError, 'test')
        end
      end

      context 'when :error_handler set' do
        let(:ses_options) { { stub_responses: true, error_handler: ->(a, b) {} } }

        it 'calls the error handler' do
          expect(ses_options[:error_handler]).to receive(:call).and_call_original
          ses.deliver!(mail)
        end
      end
    end
  end

  describe '::build_raw_email_options' do
    let(:options) { {} }
    subject { described_class.build_raw_email_options(mail, options) }
    before { allow(mail).to receive(:to_s).and_return('Fixed message body') }

    context 'without options' do
      let(:exp) do
        {
          from_email_address: 'from@abc.com',
          destination: {
            to_addresses: to,
            cc_addresses: cc,
            bcc_addresses: bcc,
          },
          content: {
            raw: {
              data: 'Fixed message body'
            }
          }
        }
      end

      it { expect(subject).to eq(exp) }
    end

    context 'with options' do
      let(:options) do
        { from_email_address: 'source@source.com',
          from_email_address_identity_arn: 'from_arn',
          feedback_forwarding_email_address: 'feedback@feedback.com',
          feedback_forwarding_email_address_identity_arn: 'feedback_arn',
          email_tags: [{ name: 'Name', value: 'Value' }],
          configuration_set_name: 'configuration_set_name',
          other: 'other' }
      end

      let(:exp) do
        {
          from_email_address: 'source@source.com',
          from_email_address_identity_arn: 'from_arn',
          feedback_forwarding_email_address: 'feedback@feedback.com',
          feedback_forwarding_email_address_identity_arn: 'feedback_arn',
          email_tags: [
            { name: 'Name', value: 'Value' }
          ],
          configuration_set_name: 'configuration_set_name',
          destination: {
            to_addresses: to,
            cc_addresses: cc,
            bcc_addresses: bcc,
          },
          content: {
            raw: {
              data: 'Fixed message body'
            }
          }
        }
      end

      it { expect(subject).to eq(exp) }
    end
  end
end
