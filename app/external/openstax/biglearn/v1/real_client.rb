class OpenStax::Biglearn::V1::RealClient

  def initialize(biglearn_configuration)
    @server_url   = biglearn_configuration.server_url
    @client_id    = biglearn_configuration.client_id
    @secret       = biglearn_configuration.secret

    @oauth_client = OAuth2::Client.new(@client_id, @secret, site: @server_url)

    @oauth_token  = @oauth_client.client_credentials.get_token unless @client_id.nil?
  end

  def add_exercises(exercises)
    options = { body: construct_exercises_payload(exercises).to_json }
    response = request(:post, add_exercises_uri, with_content_type_header(options))
    handle_response(response)
  end

  def get_exchange_read_identifiers_for_roles(roles:)
    users = Role::GetUsersForRoles[roles]
    UserProfile::Models::Profile.where(entity_user: users)
                                .collect{ |p| p.exchange_read_identifier }
  end

  def get_projection_exercises(role:, tag_search:, count:, difficulty:, allow_repetitions:)
    query = {
      learner_id: get_exchange_read_identifiers_for_roles(roles: role).first,
      number_of_questions: count,
      tag_query: stringify_tag_search(tag_search),
      allow_repetition: allow_repetitions ? 'true' : 'false'
    }

    response = request(:get, projection_exercises_uri(query))

    result = handle_response(response)

    # Return the UIDs
    result["questions"].collect { |q| q["question"] }
  end

  def stringify_tag_search(tag_search)
    case tag_search
    when Hash
      raise IllegalArgument, "too many hash conditions" if tag_search.size != 1
      stringify_tag_search_hash(tag_search.first)
    when String
      '"' + tag_search + '"'
    else
      raise IllegalArgument
    end
  end

  # Return a CLUE value for the specified set of roles and the group of tags.  May return
  # nil if no CLUE is available (e.g. no exercises attached to these tags).
  #
  # Biglearn can actually take multiple sets of tag queries at once and return a CLUE
  # for each; we're not using that capability yet. When we do we'll probably rename the
  # `tags` argument to `tag_sets` or something (or we'll make a first class `TagSearch`
  # citizen inside this module and accept an array of those into this method).
  def get_clue(roles:, tags:)
    raise "Some tags must be specified when getting a CLUE" if tags.blank?
    raise "At least one role must be specified when getting a CLUE" if roles.blank?

    tag_search = stringify_tag_search(:_or => tags)

    query = {
      learners: get_exchange_read_identifiers_for_roles(roles: roles), aggregations: tag_search
    }

    response = request(:get, clue_uri(query))

    result = handle_response(response)

    # extract the clue using the knowledge that we have a simplified input (only one
    # tag query, so we can just pull out the appropriate value).  It could be that there's
    # no CLUE to give, in which case we return nil.
    clue = result.try(:[], "aggregates").try(:first).try(:[], "aggregate")
  end

  private

  def stringify_query_hash(query_hash)
    # Standard Rails `to_query` method converts an array (blah = [1,2,3])
    # to "blah[]=1&blah[]=2&blah[]=3", but Biglearn doesn't like the brackets,
    # which get encoded as '%5B%5D' so take them out

    query_hash.to_query.remove('%5B%5D')
  end

  def with_content_type_header(options = {})
    options[:headers] ||= {}
    options[:headers].merge!('Content-Type' => 'application/json')
    options
  end

  def request(*args)
    (@oauth_token || @oauth_client).request(*args)
  end

  def add_exercises_uri
    uri = Addressable::URI.parse(@server_url)
    uri.path = '/facts/questions'
    uri
  end

  def projection_exercises_uri(query)
    uri = Addressable::URI.parse(@server_url)
    uri.path = '/projections/questions'
    uri.query = query.to_query
    uri
  end

  def clue_uri(query)
    uri = Addressable::URI.parse(@server_url)
    uri.path = '/knowledge/clue'
    uri.query = stringify_query_hash(query)
    uri
  end

  def construct_exercises_payload(exercises)
    payload = { question_tags: [] }
    [exercises].flatten.each do |exercise|
      payload[:question_tags].push(question_id: exercise.url, tags: exercise.tags)
    end
    payload
  end

  def handle_response(response)
    raise "BiglearnError #{response.status}:\n#{response.body}" if response.status != 200

    JSON.parse(response.body)
  end

  def stringify_tag_search_hash(conditions)
    case conditions[0]
    when :_and
      str = '('
      str += join_tag_searches(conditions[1], 'AND')
      str += ')'
    when :_or
      str = '('
      str += join_tag_searches(conditions[1], 'OR')
      str += ')'
    else
      raise NotYetImplemented, "Unknown boolean symbol #{conditions[0]}"
    end
  end

  def join_tag_searches(tag_searches, op)
    [tag_searches].flatten.collect { |ts| stringify_tag_search(ts) }.join(" #{op} ")
  end

end
