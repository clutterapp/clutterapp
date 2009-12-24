require 'string_rand_extension'


class Prop < ActiveRecord::Base
  self.abstract_class = true
  
  
  def self::class_from_type(type)
    unless type.instance_of?(Class)
      type = type.to_s.underscore.classify
      type << 'Prop' unless type =~ /Prop$/
      type = type.constantize
    end
    raise %{type "#{type}" must be a subclass of Prop (not "Prop" itself; empty string passed in?)} unless type.superclass == Prop
    type
  end
  
  def self::short_name
    name = self.to_s
    raise NameError.new('all prop sub-classes must end in the word "Prop"', name) unless name =~ /Prop$/
    name = name[0...-('Prop'.length)]
    name.underscore.dasherize
  end
  
  def <=>(other)
    # sort in the same order as the Prop::types() array
    Prop.types.index(self.class) <=> Prop.types.index(other.class)
  end
  
  
  def self::types
    [TextProp, CheckProp, PriorityProp, TagProp, TimeProp, NoteProp, PileRefProp]
  end
  
  def self::badgeable_types
    @badgeable_types ||= types.select {|t| t.badgeable? }
  end
  def self::non_badgeable_types
    @non_badgeable_types ||= types - badgeable_types
  end
  
  def self::stackable_types
    @stackable_types ||= types.select {|t| t.stackable? }
  end
  def self::non_stackable_types
    @non_stackable_types ||= types - stackable_types
  end
  
  def self::nodeable_types
    @nodeable_types ||= types.select {|t| t.nodeable? }
  end
  def self::non_nodeable_types
    @non_nodeable_types ||= types - nodeable_types
  end
  
  def self::deepable_types
    @deepable_types ||= types.select {|t| t.deepable? }
  end
  def self::non_deepable_types
    @non_deepable_types ||= types - deepable_types
  end
  
  
  def self::rand_new
    types.rand.rand_new
  end
  
  def self::filler_new
    raise NotImplementedError
  end
  
  
  def self::abilities
    [:badgeable, :stackable, :nodeable, :deepable]
  end
  
  
  # allows badge-style placement
  def self::badgeable?; false; end
  
  def self::is_badgeable
    class_eval(<<-EOS, __FILE__, __LINE__)
      def self::badgeable?; true; end
    EOS
  end
  
  def badged?
    self.class.badgeable? ? true : false # if badgeable, then always badged, for now; will be position-dependent eventually
  end
  
  
  # allows more than one of each on a parent node
  def self::stackable?; false; end
  
  def self::is_stackable
    class_eval(<<-EOS, __FILE__, __LINE__)
      def self::stackable?; true; end
    EOS
  end
  
  
  # allow child nodes
  def self::nodeable?; false; end
  
  def self::is_nodeable
    class_eval(<<-EOS, __FILE__, __LINE__)
      def self::nodeable?; true; end
    EOS
  end
  
  
  # allows "deep" placement (any deeper than a child of the root node)
  def self::deepable?; true; end
  
  def self::isnt_deepable
    class_eval(<<-EOS, __FILE__, __LINE__)
      def self::deepable?; false; end
    EOS
  end
  
end
