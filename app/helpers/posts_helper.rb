# frozen_string_literal: true

module PostsHelper
  def render_links(text)
    # Don't forget to escape the '.' because regex!
    permitted_sites = %w[
      (?:stackoverflow|superuser|serverfault|askubuntu|stackapps)\\.com
      mathoverflow\\.net
      \\w*.\\.stackexchange\\.com
      m(?:etasmoke)?\\.erwaysoftware\\.com
    ]
    raw(text.split(%r{((?:https?:)?/{2}(?:#{permitted_sites.join('|')})[^)<\s]*)}).map.with_index do |s, i|
      i.even? ? html_escape(s) : link_to(s, s)
    end.join)
  end
end
