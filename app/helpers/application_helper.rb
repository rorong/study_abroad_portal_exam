module ApplicationHelper
    def back_button(default = root_path, text = 'Back')
      link_to text, request.referer || default, class: 'btn btn-secondary'
    end
end
  