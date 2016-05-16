ENV['RACK_ENV'] = 'test'

require_relative 'routes_review'
require 'capybara/rspec'

Capybara.app = Sinatra::Application

Capybara.default_driver = :selenium
Capybara.default_max_wait_time = 5

describe 'loading the site', :type => :feature do
  before do
    visit '/'
  end

  it 'shows the header' do
    expect(page).to have_content 'Know Your Rails Routes!'
  end

  it 'shows 5 blanks' do
    expect(page).to have_selector('input', count: 5)
  end
end

describe 'choosing a different level' , :type => :feature do
  before do
    visit '/'
  end

  it 'shows 10 blanks for Hard' do
    click_link 'Hard'
    expect(page).to have_selector('input', count: 10)
  end

  it 'shows 20 blanks for Extreme' do
    click_link 'Extreme'
    expect(page).to have_selector('input', count: 20)
  end

  it 'shows 27 blanks for Chuck Norris' do
    click_link 'Chuck Noris'
    expect(page).to have_selector('input', count: 27)
  end
end

describe 'after entering a correct answer' , :type => :feature do
  before do
    visit '/chuck_noris'
  end

  it 'shows the answer' do
    if page.has_css?('input#index_http_verb')
      find('input#index_http_verb').send_keys('GET', :enter)

      within(:css, '#index_http_verb_cell') do
        expect(page).to have_content('GET')
      end
    else
      find('input#new_http_verb').send_keys('GET', :enter)

      within(:css, '#new_http_verb_cell') do
        expect(page).to have_content('GET')
      end
    end
  end

  it 'turns the background color green' do
    if page.has_css?('input#index_http_verb')
      find('input#index_http_verb').send_keys('GET', :enter)
    else
      find('input#new_http_verb').send_keys('GET', :enter)
    end

    expect(page).to have_css('.success')
  end
end

describe 'after entering an incorrect answer' , :type => :feature do
  before do
    visit '/chuck_noris'
  end

  it 'does not show the answer' do
    if page.has_css?('input#index_http_verb')
      find('input#index_http_verb').send_keys('???', :enter)

      within(:css, '#index_http_verb_cell') do
        expect(page).not_to have_content('GET')
      end
    else
      find('input#new_http_verb').send_keys('???', :enter)

      within(:css, '#new_http_verb_cell') do
        expect(page).not_to have_content('GET')
      end
    end
  end

  it 'turns the background color red' do
    if page.has_css?('input#index_http_verb')
      find('input#index_http_verb').send_keys('???', :enter)
    else
      find('input#new_http_verb').send_keys('???', :enter)
    end

    expect(page).to have_css('.pass')
  end
end

describe 'viewing the answers' , :type => :feature do
  before do
    visit '/'
  end

  it 'shows the answers' do
    click_link 'Answers'
    click_link 'Photos'
    expect(page).to have_content 'photos#index'
    expect(page).not_to have_selector('input')
  end
end
