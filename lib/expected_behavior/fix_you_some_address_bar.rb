module ExpectedBehavior
  module FixYouSomeAddressBar

    def self.included(controller)
      controller.extend(ClassMethods)
      controller.send(:attr_accessor, :fixed_address_bar_path)
      controller.alias_method_chain :default_template_name, :set_fixed_address_bar_path
      controller.after_filter(:fix_you_some_address_bar, :only => [:create, :update])
      controller.fix_you_some_address_bar_request_types :post, :put
    end
    
    def default_template_name_with_set_fixed_address_bar_path(action_name = self.action_name)
      if action_name != self.action_name && self.fixed_address_bar_path.blank?
        #make sure that there is actually a route for the given controller/action combo
        unless ActionController::Routing::Routes.routes_for_controller_and_action_and_keys(controller_name, action_name, { }).empty?
          self.fixed_address_bar_path = url_for(:controller => controller_name, :action => action_name, :only_path => true)
        end
      end
      default_template_name_without_set_fixed_address_bar_path(action_name)
    end
    
    def can_fix_you_some_address_bar?
      self.fixed_address_bar_path.present? &&
        (self.class.read_inheritable_attribute(:fix_you_some_address_bar_request_types) || []).include?(request.request_method)
    end
    
    def fix_you_some_address_bar_javascript
      path = self.fixed_address_bar_path
      <<-HTML
        <script type="text/javascript">
          //<![CDATA[
            if(window && window.history && window.history.replaceState)
            { window.history.replaceState("#{path}", "#{path}", "#{path}"); }
          //]]>
        </script>
      HTML
    end
    
    def fix_you_some_address_bar
      if can_fix_you_some_address_bar? && response.body.respond_to?(:sub!)
        response.body.sub!(/(<[hH][eE][aA][dD][^>]*>)/, "\\1#{fix_you_some_address_bar_javascript}") 
      end
      self.fixed_address_bar_path = nil
    end
    
    module ClassMethods
      
      def fix_you_some_address_bar_request_types(*types)
        write_inheritable_array(:fix_you_some_address_bar_request_types, types)
      end
      
    end
    
  end
end
