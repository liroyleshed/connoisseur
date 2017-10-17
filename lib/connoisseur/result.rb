class Connoisseur::Result
  class Invalid < StandardError; end

  def initialize(response)
    @response = response
  end

  # Public: Determine whether a comment is spam.
  #
  # Returns a boolean indicating whether Akismet recognizes the comment as spam.
  def spam?
    response.body == "true"
  end

  # Public: Determine whether a comment is egregious spam which should be discarded.
  #
  # Returns a boolean indicating whether Akismet recommends discarding the comment.
  def discard?
    response.headers["X-Akismet-Pro-Tip"] == "discard"
  end


  # Public: Validate the response from the Akismet API.
  #
  # Ensures that the response has a successful status code (in the range 200..300) and that the
  # response body contains a boolean.
  #
  # Returns the receiving Result.
  # Raises Connoisseur::Result::Invalid if the Akismet API provided an unexpected response.
  def validated
    require_successful_response
    require_boolean_response_body

    self
  end

  private

  attr_reader :response

  def require_successful_response
    raise Invalid, "Expected successful response, got #{response.code}" unless response.success?
  end

  def require_boolean_response_body
    unless %w( true false ).include?(response.body)
      if message = response.headers["X-Akismet-Debug-Help"]
        raise Invalid, "Expected boolean response body, got #{response.body.inspect} (#{message})"
      else
        raise Invalid, "Expected boolean response body, got #{response.body.inspect}"
      end
    end
  end
end
