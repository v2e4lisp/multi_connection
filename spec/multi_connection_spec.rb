RSpec.describe MultiConnection do

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

end
