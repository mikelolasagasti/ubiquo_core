# TODO: Look for a better way to do this (include classmethods and instance methods or at least make clear the intention).
module Ubiquo
  module Extensions
    module ActiveRecord
      
      def paginate(options = {})
        options.delete_if{|o1,o2| o2.blank? }
        options.reverse_merge!({:page => 1, :per_page => Ubiquo::Config.get(:elements_per_page) }) 
        items = self.with_scope(:find => {:limit => (options[:per_page].to_i + 1), :offset => (options[:per_page].to_i * (options[:page].to_i - 1))}) do
          yield
        end
        [
         {
           :previous => (options[:page].to_i > 1 ? options[:page].to_i - 1 : nil),
           :next => (items.delete_at(options[:per_page].to_i).nil? ? nil : options[:page].to_i + 1)
         },
         items
        ]
      end
      
      
      # Intermediate method customing paperclip has_attached_file
      # Its send path how a lambda allowing change a media folder container
      # Elsewhere, call paperclip with id_partition (folders style 000/000/001) in path and url params
      
      def file_attachment(field, options = {})
        options.reverse_merge!(Ubiquo::Config.get(:attachments))
        visibility = options[:visibility]
        
        # Comment it because we didn't achieved run path with lambda        
        # v = nil
        # path = lambda { |obj|
        #   v = visibility.is_a?(Proc) ? visibility.call(obj.instance) : visibility
        #   v_path = options["#{v}_path".to_sym]
        #   ":rails_root/#{v_path}/media/:attachment/:id_partition/:style/:basename.:extension"
        # }
        path = ":rails_root/#{visibility}/media/:attachment/:id_partition/:style/:basename.:extension"
        define_method("#{field}_is_public?") do 
          visibility.to_sym == :public
        end
        styles = options[:styles] || {}
        has_attached_file field, :path => path, :url => "/media/:attachment/:id_partition/:style/:basename.:extension", :styles => styles
      end
      
      # Function for apply an array of scopes.
      # see self.create_scopes documentation for an example
      
      def apply_find_scopes(scopes, &initial)
        scopes.compact.inject(initial) do |block, value|
          Proc.new do
            with_scope({:find => value}, &block)
          end
        end.call
      end
      
      # iterate over filters and stores each returned value in an array.
      # returns an array with all returned values of each iteration.
      # example of usage:
      #
      # scopes = create_scopes(filters) do |filter, value|
      #   case filter
      #   when :string
      #     {:conditions => ["tasks.name ILIKE ? or tasks.description ILIKE ?", "%#{value}%", "%#{value}%"]}
      #   when :time
      #     case value.to_s
      #     when "current"
      #       {:conditions => ["tasks.status < 100"]}
      #     when "old"
      #       {:conditions => ["tasks.status = 100"]}
      #     end
      #   when :project
      #     {:conditions => ["tasks.project_id = ?", value.to_i]}
      #   when :type
      #     {:conditions => ["tasks.task_type_id = ?", value.to_i]}
      #   when :ubiquo_user
      #     {:conditions => ["tasks.owner_id = ?", value.to_i]}
      #   when :current_ubiquo_user
      #     scope_options_for_ubiquo_user(value)
      #   end
      # end
      # apply_find_scopes(scopes) do
      #   find(:all, :include => [:task_type, :owner, {:project => [:owner, :project_permissions]}])
      # end
      
      def create_scopes(filters)
        filters.inject([]) do |acc, (key, value)|
          next acc if value.nil? || (value.respond_to?(:empty?) ? value.empty? : false)
          scope = yield(key, value)
          acc + [scope]
        end
      end
    end
  end
end
