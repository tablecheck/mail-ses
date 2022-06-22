# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mail::SES::OptionsBuilder do
  describe 'build' do
    let(:mail) do
      Mail.new do
        from 'from@abc.com'
        to %w[to1@def.com to2@xyz.com]
        cc %w[cc1@xyz.com cc2@def.com]
        bcc %w[bcc1@abc.com bcc2@def.com]
        body 'This is the body'
      end
    end
    let(:options) { {} }

    subject { described_class.new(mail, options).build }
    before { allow(mail).to receive(:to_s).and_return('Fixed message body') }

    context 'without options' do
      let(:exp) do
        {
          from_email_address: 'from@abc.com',
          destination: {
            to_addresses: %w[to1@def.com to2@xyz.com],
            cc_addresses: %w[cc1@xyz.com cc2@def.com],
            bcc_addresses: %w[bcc1@abc.com bcc2@def.com]
          },
          content: {
            raw: {
              data: 'Fixed message body'
            }
          }
        }
      end

      it { expect(subject).to eq(exp) }

      context 'without mail from' do
        before { mail.from = nil  }

        it { expect(subject.key?(:from_email_address)).to eq(false) }
      end

      context 'without mail destination' do
        before do
          mail.to = nil
          mail.cc = nil
          mail.bcc = nil
        end

        let(:exp) do
          {
            to_addresses: [],
            cc_addresses: [],
            bcc_addresses: []
          }
        end

        it { expect(subject[:destination]).to eq(exp) }
      end
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
            to_addresses: %w[to1@def.com to2@xyz.com],
            cc_addresses: %w[cc1@xyz.com cc2@def.com],
            bcc_addresses: %w[bcc1@abc.com bcc2@def.com]
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
