require 'github_api'
require 'pry'
require "google/cloud/vision"
require 'watir'

@browser = Watir::Browser.new
@browser.goto 'https://play.rubyconference.by/game'
# @browser.goto 'file:///home/chakra/work/kek.html'

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
  text = @vision.image(img_path).text.text.split(/\n/).join(' ')
end

def compared_str(source_s, github_s)
  words_from(source_s) == words_from(github_s)
end

def pr_title
  title = @browser.div(class: 'pull-request-title')
end

def pr_title_img
  title = @browser.img(class: 'pull-request-title_as_image')
end

def click_answer(text)
  @browser.button(text: text).click
  @browser.wait(30)
  click_next_task
end

def try(object, method)
  object.respond_to?(method) ? object.__send__(method) : object
end

def click_next_task
  @browser.button(text: 'Next task').click
end

def any_header_exist?
  pr_title.exist? || pr_title_img.exist? 
end

def pr_title_old?
  pr_title.text != @header
end

def pr_title_img_old?
  try(pr_title_img, :src) != @old_img_url
end

# @head_img_counter = 14
@head_img_counter = 0
@browser.wait_until(200){ any_header_exist? }
@header = ''
@old_img_url = '' 

loop do
  if 
  if @head_img_counter < 15 
    @browser.wait_until(6) { pr_title_old? }
  else
    @browser.wait_until(10) { pr_title_img_old? }
    @old_img_url = pr_title_img.src 
  end

  @header = pr_title_img.exist? ? img2text(try(pr_title_img, :src)) : pr_title.text 

  @head_img_counter += 1
  # system "sleep 2"

  # @@header = img_level ? img2text(`xclip -o`) : `xclip -o` 

  searcher = Github::Client::Search.new(oauth_token: 'af7661daa1ae7eb870e8a0089812a2d533bc0b83')
  result = -1
  result = searcher.issues(q: github_search_query(@header)).body.items.inject(0) do |res_count, issue|
    p words_from(issue[:title])
    res_count += compared_str(@header, issue[:title]) ? 1 : 0
  end

  # @browser.wait_until{ result != -1 }

  # @browser.wait(20)
  result += 1 if EXCEPTIONS_MERGED.include?(@header)
  result = 0 if EXCEPTIONS_REJECTED.include?(@header)
  puts "result: #{result}"
  p words_from(@header)
  puts github_search_query(@header)
  result > 0 ? p('MERGED') : p('REJECTED')
  puts "COUNTER: #{@head_img_counter}\nOLD_IMG_URL: #{@old_img_url}"
  result > 0 ? click_answer('Merged') : click_answer('Rejected')
end
