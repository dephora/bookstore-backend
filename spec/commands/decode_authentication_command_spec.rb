# frozen_string_literal: true

describe DecodeAuthenticationCommand do
  context 'without token' do
    subject { described_class.call('') }

    it { expect(subject.success?).to_not be }
    it { expect(subject.errors.keys).to include(:token) }
    it { expect(subject.errors.values.flatten).to include('Missing token') }
  end

  context 'with expired token' do
    let!(:user) { create(:user, id: 1) }
    let(:expired_header) do
      {
        'Authorization' => 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHBpcmF0aW9uIjoxNDgzMzE1MjAxfQ' \
                           '.bMict_biZTOT545LKhD_RqnpY9GPmHiagtrR9sFSBPo'
      }
    end

    subject { described_class.call(expired_header) }

    it { expect(subject.success?).to_not be }
    it { expect(subject.errors.keys).to include(:token) }
    it { expect(subject.errors.values.flatten).to include('Token is expired') }
  end

  context 'with invalid token' do
    before { Timecop.freeze(2017, 1, 1) }
    after { Timecop.return }

    let(:expired_header) do
      {
        'Authorization' => 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHBpcmF0aW9uIjoxNDgzMzE1MjAxfQ' \
                           '.bMict_biZTOT545LKhD_RqnpY9GPmHiagtrR9sFSBPo'
      }
    end

    subject { described_class.call(expired_header) }

    it { expect(subject.success?).to_not be }
    it { expect(subject.errors.keys).to include(:token) }
    it { expect(subject.errors.values.flatten).to include('Token is invalid') }
  end

  context 'with valid token' do
    before { Timecop.freeze(2017, 1, 1) }
    after { Timecop.return }
    let!(:user) { create(:user, id: 1) }

    let(:expired_header) do
      {
        'Authorization' => 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHBpcmF0aW9uIjoxNDgzMzE1MjAxfQ' \
                           '.bMict_biZTOT545LKhD_RqnpY9GPmHiagtrR9sFSBPo'
      }
    end

    subject { described_class.call(expired_header) }

    it { expect(subject.success?).to be }
    it { expect(subject.errors).to be_empty }
  end
end
