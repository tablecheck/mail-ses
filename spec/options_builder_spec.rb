# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mail::SES::OptionsBuilder do
  describe 'build' do
    let(:mail) do
      Mail.new do
        from '"My From" <from@abc.com>'
        reply_to ['reply-to1@def.com', '', 'My Reply-To <rt@qqq.com>']
        to ['to1@def.com', 'My To <to2@xyz.com>', '']
        cc ['', 'cc1@xyz.com', 'My CC <cc2@def.com>']
        bcc ['My BCC <bcc1@abc.com>', '', 'bcc2@def.com']
        body 'This is the body'
      end
    end
    let(:options) { {} }

    subject { described_class.new(mail, options).build }
    before { allow(mail).to receive(:to_s).and_return('Fixed message body') }

    context 'without options' do
      let(:exp) do
        {
          from_email_address: 'My From <from@abc.com>',
          reply_to_addresses: ['reply-to1@def.com', 'My Reply-To <rt@qqq.com>'],
          destination: {
            to_addresses: ['to1@def.com', 'My To <to2@xyz.com>'],
            cc_addresses: ['cc1@xyz.com', 'My CC <cc2@def.com>'],
            bcc_addresses: ['My BCC <bcc1@abc.com>', 'bcc2@def.com']
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
          reply_to_addresses: ['reply-to1@def.com', 'My Reply-To <rt@qqq.com>'],
          destination: {
            to_addresses: ['to1@def.com', 'My To <to2@xyz.com>'],
            cc_addresses: ['cc1@xyz.com', 'My CC <cc2@def.com>'],
            bcc_addresses: ['My BCC <bcc1@abc.com>', 'bcc2@def.com']
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

    context 'when addresses contain non-ascii chars' do
      let(:mail) do
        Mail.new do
          from '了承ございます <test@utf8.com>'
          reply_to ['了承ございます. <test@utf8.com>', '', 'My Reply-To <rt@qqq.com>']
          to ['to1@def.com', 'To テスト <to2@xyz.com>', '']
          cc ['', 'cc1@xyz.com', 'CC テスト <cc2@def.com>']
          bcc ['BCC テストです。 <bcc1@abc.com>', '', 'bcc2@def.com']
          body 'This is the body'
        end
      end

      let(:exp) do
        {
          from_email_address: '=?UTF-8?B?5LqG5om/44GU44GW44GE44G+44GZ?= <test@utf8.com>',
          reply_to_addresses: ['=?UTF-8?B?5LqG5om/44GU44GW44GE44G+44GZLg==?= <test@utf8.com>', 'My Reply-To <rt@qqq.com>'],
          destination: {
            to_addresses: ['to1@def.com', '=?UTF-8?B?VG8g44OG44K544OI?= <to2@xyz.com>'],
            cc_addresses: ['cc1@xyz.com', '=?UTF-8?B?Q0Mg44OG44K544OI?= <cc2@def.com>'],
            bcc_addresses: ['=?UTF-8?B?QkNDIOODhuOCueODiOOBp+OBmeOAgg==?= <bcc1@abc.com>', 'bcc2@def.com']
          },
          content: { raw: { data: 'Fixed message body' } }
        }
      end

      it { expect(subject).to eq(exp) }
    end
  end
end
