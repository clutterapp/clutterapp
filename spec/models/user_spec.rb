require 'spec_helper'

describe User do
  
  before(:each) do
    @user = Factory.create(:user)
  end
  
  
  it "should be created" do
    assert_difference 'User.count' do
      u = Factory.create(:user)
      u.new_record?.should == false
    end
  end
  
  it "should require login" do
    assert_no_difference 'User.count' do
      u = User.create( Factory.attributes_for(:user).merge!(:login => nil) )
      u.errors.on(:login).should_not be_nil
    end
  end
  
  it "should require password" do
    assert_no_difference 'User.count' do
      u = User.create( Factory.attributes_for(:user).merge!(:password => nil) )
      u.errors.on(:password).should_not be_nil
    end
  end
  
  it "should require password confirmation" do
    assert_no_difference 'User.count' do
      u = User.create( Factory.attributes_for(:user).merge!(:password_confirmation => nil) )
      u.errors.on(:password_confirmation).should_not be_nil
    end
  end
  
  it "should require email" do
    assert_no_difference 'User.count' do
      u = User.create( Factory.attributes_for(:user).merge!(:email => nil) )
      u.errors.on(:email).should_not be_nil
    end
  end
  
  
  it "should reset password" do
    u = Factory.create(:user, :login => 'original_username', :password => 'or1ginalP4ssword')
    u.update_attributes(:password => 'n3wP4ssword', :password_confirmation => 'n3wP4ssword')
    User.authenticate('original_username', 'n3wP4ssword').should == u
  end
  
  it "should not rehash password" do
    u = Factory.create(:user, :login => 'original_username', :password => 'or1ginalp4ssword')
    u.update_attributes(:login => 'new_username')
    User.authenticate('new_username', 'or1ginalp4ssword').should == u
  end
  
  
  it "should authenticate user" do
    u = Factory.create(:user, :login => 'alpha1', :password => 's3cret')
    User.authenticate('alpha1', 's3cret').should == u
  end
  
  it "shouldn't authenticate user with incorrect password" do
    u = Factory.create(:user, :login => 'alpha1', :password => 's3cret')
    User.authenticate('alpha1', 'inc0rrect').should_not == u
  end
  
  
  it "should set remember token" do
    @user.remember_me
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
  end
  
  it "should unset remember token" do
    @user.remember_me
    assert_not_nil @user.remember_token
    @user.forget_me
    assert_nil @user.remember_token
  end
  
  it "should remember me for one week" do
    before = 1.week.from_now.utc
    @user.remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
    assert @user.remember_token_expires_at.between?(before, after)
  end
  
  it "should remember me until one week" do
    time = 1.week.from_now.utc
    @user.remember_me_until time
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
    assert_equal @user.remember_token_expires_at, time
  end
  
  it "should remember me default two weeks" do
    before = 2.weeks.from_now.utc
    @user.remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
    assert @user.remember_token_expires_at.between?(before, after)
  end
  
  
  it "should create 2 Piles, when creating 2 Users" do
    assert_difference 'Pile.count', +2 do
      u1, u2 = 2.times { Factory.create(:user) }
    end
  end
  
  it "should create 1 Pile for each new user, when creating 2 Users" do
    u1, u2 = Factory.create(:user), Factory.create(:user)
    
    u1.piles.count.should == 1
    Pile.find_all_by_owner_id(u1.id).count.should == 1
    Pile.find_all_by_owner_id(u2.id).count.should == 1
  end
  
  it "should create 2 Nodes, when creating 2 Users" do
    assert_difference 'Node.count', +2 do
      u1, u2 = 2.times { Factory.create(:user) }
    end
  end
  
  it "should create 1 Node for each new User, when creating 2 Users" do
    u1, u2 = Factory.create(:user), Factory.create(:user)
    
    Node.all.select {|n| n.root.pile.owner == u1 }.count.should == 1
    Node.all.select {|n| n.root.pile.owner == u2 }.count.should == 1
  end
  
end