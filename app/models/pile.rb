class Pile < ActiveRecord::Base
  belongs_to :owner, :class_name => User.name, :inverse_of => :piles
  validates_presence_of :owner
  
  validates_length_of :name, :within => 1..255
  
  has_many :nodes, :dependent => :destroy, :inverse_of => :pile
  
  
  # Shares associations
  has_many :shares
  #has_many :users, :through => :shares
  
  has_many :public_shares
  accepts_nested_attributes_for :public_shares, :allow_destroy => true
  has_many :specific_user_shares
  accepts_nested_attributes_for :specific_user_shares, :allow_destroy => true
  
  named_scope :shared_publicly, :joins => :public_shares
  
  named_scope :shared_with_user, lambda {|sharee_user|
    { :joins => :specific_user_shares, :conditions => {:shares => {:sharee_id => sharee_user.id}} }
  }
  named_scope :shared_by_user, lambda {|owner_user|
    { :joins => :shares, :conditions => {:piles => {:owner_id => owner_user.id}} }
  }
  
  
  has_one :pile_ref_prop, :foreign_key => 'ref_pile_id'
  
  #validates_presence_of   :root_node, :message => 'is required'
  
  belongs_to :root_node, :class_name => Node.name
  carpesium :root_node
  #before_validation_on_create :build_root_node
  #after_create :save_root_node!
  
  
  def after_initialize
    if new_record?
      build_root_node if self.root_node.nil?
    end
  end
  
  def build_root_node(attrs = {})
    self.root_node = self.nodes.build(attrs)
  end
  
  
  # helpers for the sharing settings on this Pile (primarily for the owner)
  
  # helpers for permission determination, whether effective or explicitly set
  #   accessible: can access it in any way
  #   observable: can view it in a view-only state; mutually exclusive with modifiable
  #   modifiable: can modify and change it; mutually exclusive with observable
  
  def accessible?(inheriting = true)
    return !!( accessible_publicly?(inheriting) || accessible_by_users?(inheriting) )
  end
  def observable?(inheriting = true)
    return !!( observable_publicly?(inheriting) || observable_by_users?(inheriting) )
  end
  def modifiable?(inheriting = true)
    return !!( modifiable_publicly?(inheriting) || modifiable_by_users?(inheriting) )
  end
  
  def accessible_publicly?(inheriting = true)
    return !!( public_shares.exists? || (parent.accessible_publicly? if inheriting && parent) )
  end
  def observable_publicly?(inheriting = true)
    return !!( public_shares.exists?(:modifiable => false) || (parent.observable_publicly? if inheriting && parent) )
  end
  def modifiable_publicly?(inheriting = true)
    return !!( public_shares.exists?(:modifiable => true) || (parent.modifiable_publicly? if inheriting && parent) )
  end
  
  def accessible_by_users?(inheriting = true)
    return !!( specific_user_shares.exists? || (parent.accessible_by_users? if inheriting && parent) )
  end
  def observable_by_users?(inheriting = true)
    return !!( specific_user_shares.exists?(:modifiable => false) || (parent.observable_by_users? if inheriting && parent) )
  end
  def modifiable_by_users?(inheriting = true)
    return !!( specific_user_shares.exists?(:modifiable => true) || (parent.modifiable_by_users? if inheriting && parent) )
  end
  
  def accessible_by_user?(user, inheriting = true)
    return !!( user == owner || specific_user_shares.exists?(:sharee_id => user.id) || (parent.accessible_by_user?(user) if inheriting && parent) )
  end
  def observable_by_user?(user, inheriting = true)
    return !!( user == owner || specific_user_shares.exists?(:sharee_id => user.id, :modifiable => false) || (parent.observable_by_user?(user) if inheriting && parent) )
  end
  def modifiable_by_user?(user, inheriting = true)
    return !!( user == owner || specific_user_shares.exists?(:sharee_id => user.id, :modifiable => true) || (parent.modifiable_by_user?(user) if inheriting && parent) )
  end
  
  
  def root?
    self.id == self.owner.root_pile_id
  end
  
  def parent
    self.pile_ref_prop.node.pile if self.pile_ref_prop
  end
  
  def children
    @children ||= self.owner.piles.all(:joins => { :pile_ref_prop => :node }, :conditions => ['`nodes`.pile_id = ?', self.id])
  end
  
  def ancestors
    # @todo: optimize
    @ancestors ||= begin
      ancestors = []
      current_ancestor_pile = self
      while !current_ancestor_pile.root?
        current_ancestor_pile = current_ancestor_pile.parent
        ancestors << current_ancestor_pile
      end
      ancestors
    end
  end
  
  
  SHARE_PUBLICLY_DEFAULT_OPTIONS = { :modifiable => false }
  def share_publicly(options = {})
    options.reverse_merge! SHARE_PUBLICLY_DEFAULT_OPTIONS
    public_shares.create! :modifiable => options[:modifiable]
  end
  
  def unshare_publicly
    public_shares.destroy_all
  end
  
  SHARE_WITH_DEFAULT_OPTIONS = { :modifiable => false }
  def share_with(sharee, options = {})
    options.reverse_merge! SHARE_WITH_DEFAULT_OPTIONS
    specific_user_shares.create! :sharee => sharee, :modifiable => options[:modifiable]
  end
  
  def unshare_with(sharee)
    su_shares = specific_user_shares(:conditions => {:sharee => sharee}).destroy_all
  end
  
  
  
protected
  
  #def save_root_node!
  #  self.root_node.pile = self # setting owner afterwards is necessary during creation
  #  self.root_node.save!
  #  self.save!
  #end
  
end
