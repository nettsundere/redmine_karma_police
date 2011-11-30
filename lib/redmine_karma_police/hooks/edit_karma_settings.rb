module RedmineKarmaPolice
  class EditKarmaSettings < Redmine::Hook::ViewListener
    def view_users_form(context={})
      context[:controller].send(:render_to_string, {
         :partial => "hooks/karma_settings",
         :locals => context
       })
    end
    
    def view_my_account(context={})
       context[:controller].send(:render_to_string, {
         :partial => "hooks/karma_settings",
         :locals => context
       })
    end
  end
end
