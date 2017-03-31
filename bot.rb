require 'github_api'
require 'pry'
require "google/cloud/vision"
require 'watir'

# browser = Watir::Browser.new
# browser.goto 'https://play.rubyconference.by/game'

# Your Google Cloud Platform project ID
PROJECT_ID = "i-enterprise-163118"

# Instantiates a client
@vision = Google::Cloud::Vision.new project: PROJECT_ID

IMG_PATH = "./images/temp.png"
EXCEPTIONS_MERGED = [
  'Added option to set specific revision when using Subversion as SCM',
  'traditional make sense with `ActiveSupport::TaggedLogging`',
  'Escape spec path',
  'Remove arity check for Routesetttdraw',
  'Add more information to Rails 4 in README',
  'Try fixing Travis build',
  'Remove duplicated if',
  'Allow Sidekiq Client to push push bulk job with class as a String'
]

EXCEPTIONS_REJECTED = [
  'rake test:core task'
]

def words_from(string)
  string.tr('^A-Za-z', ' ').strip.squeeze(' ')
end

def github_search_query(search_value)
  %Q{language:ruby is:pr is:merged in:title "#{search_value}"} 
end

def img2text(img_path)
  # system %Q{xclip -selection clipboard -t image/png -o > #{img_path}}
  system %Q{xclip -selection clipboard -t image/png -o > #{img_path}}
  text = @vision.image(img_path).text.text.split(/\n/).join(' ')
end

def compared_str(source_s, github_s)
  words_from(source_s) == words_from(github_s)
end

def pr_title

end

loop do
  sleep 3 
  inp = gets
  img_level = inp == "w\n"
  header = img_level ? img2text(IMG_PATH) : `xclip -o` 
  # @header = img_level ? img2text(`xclip -o`) : `xclip -o` 

  searcher = Github::Client::Search.new(access_token: '3dccbec0f0818981055da5786719e7f112d0e3c5')
  result = searcher.issues(q: github_search_query(header)).body.items.inject(0) do |res_count, issue|
    p words_from(issue[:title])
    res_count += compared_str(header, issue[:title]) ? 1 : 0
  end

  result += 1 if EXCEPTIONS_MERGED.include?(header)
  result = 0 if EXCEPTIONS_REJECTED.include?(header)
  puts "result: #{result}"
  p words_from(header)
  puts github_search_query(header)
  result > 0 ? p("MERGED") : p("REJECTED")
end
