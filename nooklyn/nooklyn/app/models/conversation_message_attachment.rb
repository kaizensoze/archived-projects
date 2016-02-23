require 'uri'

class ConversationMessageAttachment

  PARSEABLE_TYPES = ['listings', 'mate_posts']
  NOOKLYN_DOMAINS = ['www.nooklyn.com', 'nooklyn.com']

  def self.extract(message)
    present_urls = PostRank::URI.extract(message)
    present_urls.map { |url| ConversationMessageAttachment.new(url) }
      .select { |cma| cma.actionable? }
  end

  def initialize(url)
    @url = url
    @type = extract_type(url) || :unextractable
    @type_id = extract_type_id(url) || :unextractable
  end

  def actionable?
    nooklyn_domain? && acceptable_type? && acceptable_type_id?
  end

  def native_type
    # raise Exception if not actionable
    case type
    when 'listings'
      Listing.find(type_id)
    when 'mate_posts'
      MatePost.find(type_id)
    end
  end

  private

  def acceptable_type?
    PARSEABLE_TYPES.include?(type)
  end

  def acceptable_type_id?
    type_id != :unextractable
  end

  def extract_type(url)
    path = URI(url).path
    path_segments = path[1..-1].split('/')
    path_segments.first
  rescue
    return nil
  end

  def extract_type_id(url)
    path = URI(url).path
    path_segments = path[1..-1].split('/')
    id_str = path_segments[1..-1].join('')

    id_str = nil if id_str.empty?
    id_str
  rescue
    return nil
  end

  def nooklyn_domain?
    url_host = URI(url).host
    NOOKLYN_DOMAINS.include?(url_host)
  end

  attr_reader :type, :type_id, :url
end
