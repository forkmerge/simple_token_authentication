require 'spec_helper'

def ignore_cucumber_hack
  skip_rails_test_environment_code
end

# Skip the code intended to be run in the Rails test environment
def skip_rails_test_environment_code
  rails = double()
  stub_const('Rails', rails)
  rails.stub_chain(:env, :test?).and_return(false)
end

def double_user_model
  user = double()
  stub_const('User', user)
  user.stub(:name).and_return('User')
end

def double_super_admin_model
  super_admin = double()
  stub_const('SuperAdmin', super_admin)
  super_admin.stub(:name).and_return('SuperAdmin')
end

describe 'A token authentication handler class (or one of its children)' do

  after(:each) do
    ensure_examples_independence
  end

  before(:each) do
    define_test_subjects_for(SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
  end

  it 'responds to :acts_as_token_authentication_handler_for', public: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authentication_handler_for
    end
  end

  it 'responds to :acts_as_token_authentication_handler', public: true, deprecated: true do
    @subjects.each do |subject|
      expect(subject).to respond_to :acts_as_token_authentication_handler
    end
  end

  describe 'which support the :before_filter hook' do


    before(:each) do
      @subjects.each do |subject|
        subject.stub(:before_filter)
      end
    end

    # User

    context 'and which acts as token authentication handler for User' do

      before(:each) do
        ignore_cucumber_hack
        double_user_model
      end

      it 'ensures its instances require user to authenticate from token or any Devise strategy before any action', public: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_filter).with(:authenticate_user_from_token!, {})
          subject.acts_as_token_authentication_handler_for User
        end
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require user to authenticate from token before any action', public: true do
          @subjects.each do |subject|
            expect(subject).to receive(:before_filter).with(:authenticate_user_from_token, {})
            subject.acts_as_token_authentication_handler_for User, options
          end
        end
      end

      describe 'instance' do

        before(:each) do
          ignore_cucumber_hack
          double_user_model

          klass = define_dummy_class_which_includes(
                    SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
          klass.class_eval do
            acts_as_token_authentication_handler_for User
          end

          child_klass = define_dummy_class_child_of(klass)
          @subjects   = [klass.new, child_klass.new]
        end

        it 'responds to :authenticate_user_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_user_from_token
          end
        end

        it 'responds to :authenticate_user_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_user_from_token!
          end
        end

        it 'does not respond to :authenticate_super_admin_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_super_admin_from_token
          end
        end

        it 'does not respond to :authenticate_super_admin_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_super_admin_from_token!
          end
        end
      end
    end

    # SuperAdmin

    context 'and which acts as token authentication handler for SuperAdmin' do

      before(:each) do
        ignore_cucumber_hack
        double_super_admin_model
      end

      it 'ensures its instances require super_admin to authenticate from token or any Devise strategy before any action', public: true do
        @subjects.each do |subject|
          expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token!, {})
          subject.acts_as_token_authentication_handler_for SuperAdmin
        end
      end

      context 'and disables the fallback to Devise authentication' do

        let(:options) do
          { fallback_to_devise: false }
        end

        it 'ensures its instances require super_admin to authenticate from token before any action', public: true do
          @subjects.each do |subject|
            expect(subject).to receive(:before_filter).with(:authenticate_super_admin_from_token, {})
            subject.acts_as_token_authentication_handler_for SuperAdmin, options
          end
        end
      end

      describe 'instance' do

        # ! to ensure it gets defined before subjects
        before(:each) do
          ignore_cucumber_hack
          double_super_admin_model

          klass = define_dummy_class_which_includes(
                    SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler)
          klass.class_eval do
            acts_as_token_authentication_handler_for SuperAdmin
          end

          child_klass = define_dummy_class_child_of(klass)
          @subjects   = [klass.new, child_klass.new]
        end

        it 'responds to :authenticate_super_admin_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_super_admin_from_token
          end
        end

        it 'responds to :authenticate_super_admin_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).to respond_to :authenticate_super_admin_from_token!
          end
        end

        it 'does not respond to :authenticate_user_from_token', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_user_from_token
          end
        end

        it 'does not respond to :authenticate_user_from_token!', protected: true do
          @subjects.each do |subject|
            expect(subject).not_to respond_to :authenticate_user_from_token!
          end
        end
      end
    end
  end
end
