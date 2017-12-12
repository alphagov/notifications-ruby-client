describe Notifications::UuidValidator do
  def assert_valid(uuid)
    expect(described_class.new(uuid)).to be_valid,
      "uuid: #{uuid} should be valid"
  end

  def assert_invalid(uuid)
    expect(described_class.new(uuid)).not_to be_valid,
      "uuid: #{uuid} should be invalid"
  end

  it "accepts valid uuids" do
    assert_valid("00000000-0000-0000-0000-000000000000")
    assert_valid("01234567-89ab-cdef-edcb-a98765432100")

    100.times { assert_valid(SecureRandom.uuid) }
  end

  it "rejects invalid uuids" do
    assert_invalid("not-a-valid-uuid")
    assert_invalid("abcdefg-0000-0000-0000-0000000000000")
    assert_invalid("000000000000000000000000000000000000")
    assert_invalid("00000000-0000-0000-0000-0000000000")
    assert_invalid("00000000------0000-0000-000000000000")
    assert_invalid(nil)
  end

  describe ".validate!" do
    context "for a valid uuid" do
      let(:uuid) { "00000000-0000-0000-0000-000000000000" }

      it "does not raise" do
        expect { described_class.validate!(uuid) }.not_to raise_error
      end
    end

    context "for an invalid uuid" do
      let(:uuid) { "not-a-valid-uuid" }

      it "raises a helpful error" do
        expect { described_class.validate!(uuid) }
          .to raise_error(ArgumentError, '"not-a-valid-uuid" is not a valid uuid')

        expect { described_class.validate!(nil) }
          .to raise_error(ArgumentError, 'nil is not a valid uuid')
      end
    end
  end
end
