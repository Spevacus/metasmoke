# frozen_string_literal: true

xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'CharcoalHQ'
    xml.description 'Posts which have been caught by Charcoal HQ'
    xml.link root_url
    # category
    xml.copyright 'Copyright 2018 CharcoalHQ'
    # docs
    xml.language 'en-us'
    xml.lastBuildDate DateTime.now.strftime('%a, %-d %b %Y %T %z')
    xml.managingEditor 'smokey@charcoal-se.org'
    xml.pubDate DateTime.now.strftime('%a, %-d %b %Y %T %z')
    xml.webMaster 'smokey@charcoal-se.org'
    xml.generator 'Ruby on Rails XML generator'

    xml.image do
      xml.url 'https://charcoal-se.org/assets/images/charcoal.png'
      xml.title 'CharcoalHQ'
      xml.link root_url
      xml.description 'Posts which have been caught by Charcoal HQ'
      xml.width 516
      xml.height 516
    end

    @posts.each do |post|
      xml.item do
        tags = []
        tags.push 'deleted' unless post.deleted_at.nil?
        tags.push 'autoflagged' if post.autoflagged
        xml.title "[#{tags.join('] [')}] #{post.title}"
        params[:prefix_user] = 'true' if params[:fullbody] == 'false' && !params[:prefix_user].present?
        description = ''
        if params[:prefix_user] == 'true'
          description = "#{link_to post.stack_exchange_user.username,
                                   post.stack_exchange_user.stack_link} #{description}"
        end
        description = "#{description} #{post.body}" unless params[:fullbody] == 'false'
        xml.description description
        case params[:link_type].to_s.downcase
        when 'user'
          xml.link post.stack_exchange_user.stack_link
        when 'onsite'
          # We rely on Post.link being a protocol-relative link.
          # This is supported by current data; there are only four exceptions from back in early '17. Won't matter for RSS.
          xml.link "https:#{post.link}"
        else
          xml.link url_for(controller: 'posts', action: 'show', id: post.id, only_path: false)
        end
        # category
        # comments
        xml.pubDate post.created_at.strftime('%a, %-d %b %Y %T %z')
      end
    end
  end
end
