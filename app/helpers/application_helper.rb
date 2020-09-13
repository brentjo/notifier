module ApplicationHelper
  def bootstrap_flash_class(type)
    type = type.to_sym
    case type
    when :success
      "alert alert-success"
    when :error
      "alert alert-danger"
    else
      raise "Unsupported flash type!"
    end
  end

  def token_url_for(token)
    "#{request.base_url}/#{token}"
  end
end
