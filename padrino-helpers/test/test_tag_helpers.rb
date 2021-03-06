require File.expand_path(File.dirname(__FILE__) + '/helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/markup_app/app')

describe "TagHelpers" do
  def app
    MarkupDemo
  end

  describe 'for #tag method' do
    it 'should support tags with no content no attributes' do
      assert_has_tag(:br) { tag(:br) }
    end

    it 'should support tags with no content with attributes' do
      actual_html = tag(:br, :style => 'clear:both', :class => 'yellow')
      assert_has_tag(:br, :class => 'yellow', :style=>'clear:both') { actual_html }
    end

    it 'should support selected attribute by using "selected" if true' do
      actual_html = tag(:option, :selected => true)
      # fix nokogiri 1.6.8 on jRuby
      actual_html = content_tag(:select, actual_html)
      assert_has_tag('option', :selected => 'selected') { actual_html }
    end

    it 'should support data attributes' do
      actual_html = tag(:a, :data => { :remote => true, :method => 'post'})
      assert_has_tag(:a, 'data-remote' => 'true', 'data-method' => 'post') { actual_html }
    end

    it 'should support nested attributes' do
      actual_html = tag(:div, :data => {:dojo => {:type => 'dijit.form.TextBox', :props => 'readOnly: true'}})
      assert_has_tag(:div, 'data-dojo-type' => 'dijit.form.TextBox', 'data-dojo-props' => 'readOnly: true') { actual_html }
    end

    it 'should support open tags' do
      actual_html = tag(:p, { :class => 'demo' }, true)
      assert_equal "<p class=\"demo\">", actual_html
    end

    it 'should escape html' do
      actual_html = tag(:br, :class => 'Example <foo> & "bar"')
      assert_equal "<br class=\"Example &lt;foo&gt; &amp; &quot;bar&quot;\" />", actual_html
    end
  end

  describe 'for #content_tag method' do
    it 'should support tags with content as parameter' do
      actual_html = content_tag(:p, "Demo", :class => 'large', :id => 'thing')
      assert_has_tag('p.large#thing', :content => "Demo") { actual_html }
    end

    it 'should support tags with content as block' do
      actual_html = content_tag(:p, :class => 'large', :id => 'star') { "Demo" }
      assert_has_tag('p.large#star', :content => "Demo") { actual_html }
    end

    it 'should escape non-html-safe content' do
      actual_html = content_tag(:p, :class => 'large', :id => 'star') { "<>" }
      assert_has_tag('p.large#star') { actual_html }
      assert_match('&lt;&gt;', actual_html)
    end

    it 'should not escape html-safe content' do
      actual_html = content_tag(:p, :class => 'large', :id => 'star') { "<>" }
      assert_has_tag('p.large#star', :content => "<>") { actual_html }
    end

    it 'should convert to a string if the content is not a string' do
      actual_html = content_tag(:p, 97)
      assert_has_tag('p', :content => "97") { actual_html }
    end

    it 'should support tags with erb' do
      visit '/erb/content_tag'
      assert_have_selector :p, :content => "Test 1", :class => 'test', :id => 'test1'
      assert_have_selector :p, :content => "Test 2"
      assert_have_selector :p, :content => "Test 3"
      assert_have_selector :p, :content => "Test 4"
      assert_have_selector :p, :content => "one"
      assert_have_selector :p, :content => "two"
      assert_have_no_selector :p, :content => "failed"
    end

    it 'should support tags with haml' do
      visit '/haml/content_tag'
      assert_have_selector :p, :content => "Test 1", :class => 'test', :id => 'test1'
      assert_have_selector :p, :content => "Test 2"
      assert_have_selector :p, :content => "Test 3", :class => 'test', :id => 'test3'
      assert_have_selector :p, :content => "Test 4"
      assert_have_selector :p, :content => "one"
      assert_have_selector :p, :content => "two"
      assert_have_no_selector :p, :content => "failed"
    end

    it 'should support tags with slim' do
      visit '/slim/content_tag'
      assert_have_selector :p, :content => "Test 1", :class => 'test', :id => 'test1'
      assert_have_selector :p, :content => "Test 2"
      assert_have_selector :p, :content => "Test 3", :class => 'test', :id => 'test3'
      assert_have_selector :p, :content => "Test 4"
      assert_have_selector :p, :content => "one"
      assert_have_selector :p, :content => "two"
      assert_have_no_selector :p, :content => "failed"
    end
  end

  describe 'for #input_tag method' do
    it 'should support field with type' do
      assert_has_tag('input[type=text]') { input_tag(:text) }
    end

    it 'should support field with type and options' do
      actual_html = input_tag(:text, :class => "first", :id => 'texter')
      assert_has_tag('input.first#texter[type=text]') { actual_html }
    end

    it 'should support checked attribute by using "checked" if true' do
      actual_html = input_tag(:checkbox, :checked => true)
      assert_has_tag('input[type=checkbox]', :checked => 'checked') { actual_html }
    end

    it 'should remove checked attribute if false' do
      actual_html = input_tag(:checkbox, :checked => false)
      assert_has_no_tag('input[type=checkbox][checked=false]') { actual_html }
    end

    it 'should support disabled attribute by using "disabled" if true' do
      actual_html = input_tag(:checkbox, :disabled => true)
      assert_has_tag('input[type=checkbox]', :disabled => 'disabled') { actual_html }
    end
  end
end
