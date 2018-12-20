class Redis::PostComment
  attr_reader :fields, :id

  def initialize(id, **overrides)
    @id = id
    @fields = overrides
  end
end
