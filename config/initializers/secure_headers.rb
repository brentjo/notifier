SecureHeaders::Configuration.default do |config|
  config.referrer_policy = "strict-origin-when-cross-origin"
  config.hsts = "max-age=#{20.years.to_i}; includeSubdomains"
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      strict: true
    }
  }
  config.csp = {
    default_src: %w('none'),
    base_uri: %w('self'),
    block_all_mixed_content: true,
    child_src: %w('self'),
    connect_src: %w('self'),
    font_src: %w('self'),
    form_action: %w('self'),
    frame_ancestors: %w('none'),
    img_src: %w('self'),
    manifest_src: %w('self'),
    object_src: %w('none'),
    script_src: %w('self'),
    style_src: %w('self')
  }
end
