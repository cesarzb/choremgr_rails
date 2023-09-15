# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user_attrs) { attributes_for(:user) }

  context 'role' do
    it 'must be present' do
      user = User.create(user_attrs.merge(role: nil))
      expect(user).not_to be_valid
    end
  end

  context 'email' do
    it 'must be present' do
      user = User.create(user_attrs.merge(email: nil))
      expect(user).not_to be_valid
    end

    it 'must be valid email address' do
      user = User.create(user_attrs.merge(email: 'aaaaaaaaa'))
      expect(user).not_to be_valid
    end

    it 'must be unique' do
      user = User.create(user_attrs.merge(email: 'valid@email.com'))
      expect(user).to be_valid
      other_user = User.create(user_attrs.merge(email: 'valid@email.com'))
      expect(other_user).not_to be_valid
    end
  end

  context 'password' do
    it 'must be longer than 5 characters' do
      user = User.create(user_attrs.merge(password: 'aaaaa',
                                          password_confirmation: 'aaaaa'))
      expect(user).not_to be_valid
    end

    it 'must be the same as password confirmation' do
      user = User.create(user_attrs.merge(password: 'Password1@',
                                          password_confirmation: 'OPassword1@'))
      expect(user).not_to be_valid
    end
  end
end
