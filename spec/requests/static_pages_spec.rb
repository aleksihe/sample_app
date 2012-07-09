require 'spec_helper'

describe "Static pages" do
  let(:base_title) { "Ruby on Rails Tutorial Sample App"}
  
  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title))}
  end
  
  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:page_title) { '' }
    
    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| Home|'}
    
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }
      
      before do
         FactoryGirl.create(:micropost, user: user, content: "Lorem ipsums") 
         sign_in user
         visit root_path
      end
      
      it "should render properly pluralized micropost count when 1 micropost" do
        page.should have_content("1 micropost") 
      end
      
    #  it "should be able to delete only own microposts" do
    #    
    #    FactoryGirl.create(:micropost, user: other_user, content: "Lorem ipsums")
    #    visit root_path
    #    get :li, :id => other_user
    #    response.should_not have_selector("a", :content => "delete")
    #  end 
      
      it "should render properly pluralized micropost count when more than one microposts" do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        visit root_path
        page.should have_content(" microposts") 
      end
      
      it "should have proper pagination if micropost count is over 30" do
        31.times do
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        end
        visit root_path
        page.should have_content(" microposts")
        page.should have_content("Next")
        click_link "Next"
        page.should have_content("Previous")
        click_link "Previous"
      end
      
      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
      
      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
    
  end
  
 describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About' }
    
    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }
    
    it_should_behave_like "all static pages"   
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end
end