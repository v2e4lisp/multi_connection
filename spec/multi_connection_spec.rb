RSpec.describe MultiConnection do

  def switch_to(spec, &block)
    ActiveRecord::Base.switch_to(spec, &block)
  end

  describe "Write to default database" do
    before { User.create }
    it { expect(User.count).to eq 1 }
    it { expect(switch_to(:db2) { User.count }).to eq 0 }
  end

  describe "Write to another database" do
    before { User.switch_to(:db2) { User.create } }
    it { expect(User.count).to eq 0 }
    it { expect(switch_to(:db2) { User.count }).to eq 1 }
  end

  it("should be thread safe") {
    Thread.new { switch_to(:db2) { User.create } }.join
    expect(User.count).to eq 0
    expect(switch_to(:db2) { User.count }).to eq 1
  }

end
