require 'rails_helper'
describe User do
  describe 'users/registrations#update_resource' do
    it 'is valid complete require data' do
      user = build(:user)
      user.valid?
      expect(user).to be_valid
    end
    it 'is invalid without a name' do
      user = build(:user, name: '')
      user.valid?
      expect(user.errors[:name]).to include('を入力してください')
    end
    it 'is invalid without an email' do
      user = build(:user, email: '')
      user.valid?
      expect(user.errors[:email]).to include('を入力してください')
    end
    it 'is invalid without a password' do
      user = build(:user, password: '')
      user.valid?
      expect(user.errors[:password]).to include('を入力してください')
    end
    it 'is invalid without a password_confirmation' do
      user = build(:user, password_confirmation: '')
      user.valid?
      expect(user.errors[:password_confirmation]).to include('とPasswordの入力が一致しません')
    end
    it 'is invalid with a duplicate email address' do
      user = create(:user)
      another_user = build(:user, email: user.email)
      another_user.valid?
      expect(another_user.errors[:email]).to include('はすでに存在します')
    end
    it 'is invalid with a name that has less than 3 characters' do
      user = build(:user, name: 'num')
      user.valid?
      expect(user.errors[:name][0]).to include('は4文字以上で入力してください')
    end
    it 'is valid with a name that has more than 4 characters' do
      user = build(:user, name: 'test')
      user.valid?
      expect(user).to be_valid
    end
    it 'is invalid with a password that has less than 5 characters' do
      user = build(:user, password: '00000', password_confirmation: '00000')
      user.valid?
      expect(user.errors[:password][0]).to include('は6文字以上で入力してください')
    end
    it 'is valid with a password that has more than 6 characters' do
      user = build(:user, password: '000000', password_confirmation: '000000')
      user.valid?
      expect(user).to be_valid
    end
  end
end
