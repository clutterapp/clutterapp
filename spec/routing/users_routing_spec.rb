require 'spec_helper'

describe UsersController do
  describe "routing" do
    
    #it "recognizes and generates #index" do
    #  { :get => "/users" }.should route_to(:controller => 'users', :action => 'index')
    #end
    
    it "recognizes and generates #new" do
      expected_path = '/sup'
      { :get => expected_path }.should route_to(:controller => 'users', :action => 'new')
      new_user_path().should == expected_path
    end
    
    it "recognizes and generates #new with an invite_token" do
      expected_path = '/sup?invite_token=a'
      { :get => expected_path }.should route_to(:controller => 'users', :action => 'new', :invite_token => 'a')
      new_user_path(:invite_token => 'a').should == expected_path
    end
    
    it "recognizes and generates #show" do
      expected_path = '/test-user'
      { :get => expected_path }.should route_to(:controller => 'users', :action => 'show', :id => 'test-user')
      user_path('test-user').should == expected_path
    end
    
    it "recognizes and generates #edit" do
      expected_path = '/test-user/edit'
      { :get => expected_path }.should route_to(:controller => 'users', :action => 'edit', :id => 'test-user')
      edit_user_path('test-user').should == expected_path
    end
    
    it "recognizes and generates #create" do
      expected_path = '/reg'
      { :post => expected_path }.should route_to(:controller => 'users', :action => 'create')
      users_path().should == expected_path
    end
    
    it "recognizes and generates #update" do
      expected_path = '/test-user'
      { :put => expected_path }.should route_to(:controller => 'users', :action => 'update', :id => 'test-user')
      user_path('test-user').should == expected_path
    end
    
    it "recognizes and generates #destroy" do
      expected_path = '/test-user'
      { :delete => expected_path }.should route_to(:controller => 'users', :action => 'destroy', :id => 'test-user')
      user_path('test-user').should == expected_path
    end
    
  end
end
