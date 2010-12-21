require 'action_controller/test_case'
require "rails_generator"
require "ubiquo/extensions/rails_238_string_concat_fix" if Rails.version == '2.3.8'

module Ubiquo
  module Extensions
    autoload :Routing,               'ubiquo/extensions/routing'
    autoload :ActiveRecord,          'ubiquo/extensions/active_record'
    autoload :DateParser,            'ubiquo/extensions/date_parser'
    autoload :Array,                 'ubiquo/extensions/array'
    autoload :String,                'ubiquo/extensions/string'
    autoload :TestImprovements,      'ubiquo/extensions/test_improvements'
    autoload :ActionView,            'ubiquo/extensions/action_view'
    autoload :ConfigCaller,          'ubiquo/extensions/config_caller'

    module RailsGenerator
      [ :Create, :Destroy, :List ].each { |m| autoload m, 'ubiquo/extensions/rails_generator' }
    end
  end
end

ActionController::Routing::RouteSet::Mapper.send(:include, Ubiquo::Extensions::Routing)
Ubiquo::Extensions::UbiquoAreaController.append_include(Ubiquo::Extensions::DateParser)
ActionView::Base.field_error_proc = Ubiquo::Extensions::ActionView.ubiquo_field_error_proc
ActiveRecord::Base.send(:extend, Ubiquo::Extensions::ActiveRecord)
Array.send(:include, Ubiquo::Extensions::Array)
String.send(:include, Ubiquo::Extensions::String)

Rails::Generator::Commands::Create.send(:include, Ubiquo::Extensions::RailsGenerator::Create)
Rails::Generator::Commands::Destroy.send(:include, Ubiquo::Extensions::RailsGenerator::Destroy)
Rails::Generator::Commands::List.send(:include, Ubiquo::Extensions::RailsGenerator::List)

if Rails.env.test?
  ActiveSupport::TestCase.send(:include, Ubiquo::Extensions::TestCase)
  ActionController::TestCase.send(:include, Ubiquo::Extensions::TestCase)
end

ActiveRecord::Base.send(:include, Ubiquo::Extensions::ConfigCaller)
ActiveRecord::Base.send(:extend, Ubiquo::Extensions::ConfigCaller)
Ubiquo::Extensions::UbiquoAreaController.append_extend(Ubiquo::Extensions::ConfigCaller)
Ubiquo::Extensions::UbiquoAreaController.append_include(Ubiquo::Extensions::ConfigCaller)
ActionView::Base.send(:include, Ubiquo::Extensions::ConfigCaller)
ActionView::Base.send(:extend, Ubiquo::Extensions::ConfigCaller)
