# frozen_string_literal: true

BASE = 8

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :post do
    type Types::PostType
    argument :id, types.ID
    argument :uid, types.ID
    argument :site, types.String
    argument :link, types.String
    resolve lambda { |_obj, args, _ctx|
      return GraphQL::ExecutionError.new('Invalid argument grouping') if [%w[uid site], ['id'], ['link']].include? args

      if args['link']
        Post.find(link: args['link'])
      elsif args['uid'] && args['site']
        posts = Post.includes(:site).where(sites: { api_parameter: args['site'] }, native_id: args['uid'])
        GraphQL::ExecutionError.new('More than one post matches those parameters') if posts.length > 1
        post.empty? ? nil : post.first
      elsif args['id']
        Post.find(args['id'])
      else
        Post.last
      end
    }
    complexity lambda { |_ctx, _args, child_complexity|
      (BASE * 25) + (child_complexity > 1 ? child_complexity : 1)
    }
  end

  field :posts do
    type types[Types::PostType]
    argument :ids, types[types.ID], 'A list of Metasmoke IDs'
    argument :uids, types[types.String],
             "A list of on-site id and site name pairs, e.g. ['stackunderflow:12345', 'superloser:54321']"
    argument :urls, types[types.String],
             'A list of urls to posts, of the form //sitename.stackexchange.com/a/id or /questions/id'
    argument :last, types.Int,
             "Last n items from selection. Can be used in conjunction with any other options except 'first'"
    argument :first, types.Int,
             "First n items from selection. Can be used in conjunction with any other options except 'last'"
    argument :offset, types.Int, 'Number of items to offset by. Offset counted from start unless ' \
                                 "the 'last' option is used, in which case offset is counted from the end.", default_value: 0
    description 'Find Posts, with a maximum of 100 to be returned'
    resolve lambda { |_obj, args, _ctx|
      posts = Post.all
      posts = posts.where(link: args['urls']) if args['urls']
      if args['uids']
        all_sites = Site.all.select(:id, :api_parameter).map { |site| [site.id, site.api_parameter] }
        uids = args['uids'].map do |uid|
          site, native_id = uid.split(':')
          site_id = all_sites.select { |_site_id, api_parameter| api_parameter == site }[0][0]
          [site_id, native_id].map(&:to_i)
        end
        all_permutations = posts.where(site_id: uids.map(&:first), native_id: uids.map(&:last))
        posts = uids.map do |site_id, native_id|
          all_permutations.select do |post|
            post.site_id == site_id && post.native_id == native_id
          end
        end.flatten.reject(&:nil?)
        posts = Post.where(id: posts.map(&:id))
      end
      posts = posts.find(args['ids']) if args['ids']
      return GraphQL::ExecutionError.new("You can't use 'last' and 'first' together") if args['first'] && args['last']

      posts = posts.offset(args['offset']).first(args['first']) if args['first']
      posts = posts.reverse_order.offset(args['offset']).first(args['last']) if args['last']
      posts = posts.limit(100) if posts.respond_to? :limit
      Array(posts)
    }
    complexity lambda { |_ctx, args, child_complexity|
      children = 0
      children += (args['last'] || args['first'] || 0)
      children += args['uids'].length if args['uids']
      children += args['ids'].length if args['ids']
      children += args['urls'].length if args['urls']
      (BASE * 25) + children * (child_complexity > 1 ? child_complexity : 1)
    }
  end

  # deletion_logs domain_tags flag_logs moderator_sites

  def gen_field(name)
    ar_class = name.camelize.constantize
    graphql_type = "Types::#{name.camelize}Type".constantize

    field name.to_sym do
      type graphql_type
      argument :id, types.ID, "Get one #{ar_class} by id"
      description "Find one #{ar_class}"
      resolve lambda { |_obj, args, _ctx|
        ar_class.find(args['id']) if args['id']
      }
      complexity lambda { |_ctx, _args, child_complexity|
        (BASE * 25) + (child_complexity > 1 ? child_complexity : 1)
      }
    end

    field name.pluralize.to_sym do
      type types[graphql_type]
      argument :ids, types[types.ID], 'A list of Metasmoke IDs'
      argument :last, types.Int,
               "Last n items from selection. Can be used in conjunction with any other options except 'first'"
      argument :first, types.Int,
               "First n items from selection. Can be used in conjunction with any other options except 'last'"
      argument :offset, types.Int, 'Number of items to offset by. Offset counted from start unless ' \
                                   "the 'last' option is used, in which case offset is counted from the end.", default_value: 0
      description "Find multiple #{ar_class.to_s.pluralize}. Maximum of 200 returned."
      resolve lambda { |_obj, args, _ctx|
        things = ar_class.all
        things = things.where(id: args['ids']) if args['ids']
        return GraphQL::ExecutionError.new("You can't use 'last' and 'first' together") if args['first'] && args['last']

        things = things.offset(args['offset']).first(args['first']) if args['first']
        things = things.reverse_order.offset(args['offset']).first(args['last']) if args['last']
        things = things.limit(200) if things.respond_to? :limit
        Array(things)
      }
      complexity lambda { |_ctx, args, child_complexity|
        children = 0
        children += args['ids'].length if args['ids']
        children += (args['last'] || args['first'] || 0)
        children = 200 if children.zero?
        (BASE * 25) + children * (child_complexity > 1 ? child_complexity : 1)
      }
    end
  end

  def gen_fields(*names)
    names.flatten.each { |name| gen_field(name) }
  end

  gen_fields %w[feedback smoke_detector site stack_exchange_user announcement
                reason user flag_log flag_condition spam_domain domain_tag]
end
