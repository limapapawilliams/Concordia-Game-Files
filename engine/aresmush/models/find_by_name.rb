# NOTE!
#
# To use this in your Ohm object, just add this to your class:
#    include FindByName
#
# Also make sure you have the following members/methods defined in your class:
#
# attribute :name
# attribute :name_upcase
#
# index :name_upcase
#
# before_save :save_upcase_name
# def save_upcase_name
#   self.name_upcase = self.name.upcase
# end

module AresMUSH
  module FindByName

    def self.included(base)
      base.send :extend, ClassMethods   
      #base.send :register_data_members
    end
 
    module ClassMethods
      #def register_data_members
      #end
    
      def find_any_by_id(id)
        prefix = id.after("#").before("-") || ""
        if (prefix.downcase == self.dbref_prefix.downcase)
          return [self[id.after("-")]]
        else
          return []
        end
      end
      
      def find_any_by_name(name_or_id)
        return [] if !name_or_id
        
        if (name_or_id.start_with?("#"))
          return find_any_by_id(name_or_id.upcase)
        end
        find(name_upcase: name_or_id.upcase).to_a.select { |x| x }
      end

      def named(name)
        find_one_by_name(name)
      end
      
      def find_one_by_name(name)
        find_any_by_name(name).first
      end
    
      def found?(name)
        !!find_one_by_name(name)
      end
      
    end
    
    def to_json
      JSON.pretty_generate(as_json)
    end
  end
end