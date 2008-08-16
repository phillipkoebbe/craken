RAILS_ROOT = "foo/bar/baz"
RAILS_ENV = "test"
ENV['app_name'] = "craken_test"

require File.dirname(__FILE__) + "/../lib/craken"

describe Craken do

  include Craken

  describe "load_and_strip" do

    it "should load the user's installed crontab" do
      # figured out how to do this from here:
      # http://jakescruggs.blogspot.com/2007/11/mocking-backticks-and-other-kernel.html
      self.should_receive(:`).with(/crontab -l/).and_return('')
      load_and_strip
    end

    it "should strip out preinstalled raketab commands associated with the project" do

crontab = <<EOS
### craken_test raketab
this is a test
one more line
### craken_test raketab end
EOS

      self.should_receive(:`).with(/crontab -l/).and_return(crontab)
      load_and_strip.should be_empty
    end

    it "should not strip out preinstalled raketab commands not associated with the project" do

crontab = <<EOS
1 2 3 4 5 blah blah
### craken_test raketab
this is a test
one more line
### craken_test raketab end
6 7 8 9 10 foo bar
EOS

      self.should_receive(:`).with(/crontab -l/).and_return(crontab)
      load_and_strip.should == "1 2 3 4 5 blah blah\n6 7 8 9 10 foo bar\n"
    end
  end

  describe "append_tasks" do
    before(:each) do
      @crontab = "1 2 3 4 5 blah blah\n6 7 8 9 10 foo bar\n"
    end

    it "should add comments to the beginning and end of the rake tasks it adds to crontab" do
      raketab = "0 1 0 0 0 foo:bar"
      cron = append_tasks(@crontab, raketab)
      cron.should match(/### craken_test raketab\n0 1 0 0 0 /)
      cron.should match(/### craken_test raketab end\n$/)
    end

    it "should ignore comments in the raketab string" do
raketab = <<EOS
# comment to ignore
0 1 0 0 0 foo:bar
# another comment to ignore
EOS
      cron = append_tasks(@crontab, raketab)
      cron.should_not match(/# comment to ignore/)
      cron.should_not match(/# another comment to ignore/)
    end

    it "should not munge the crontab time configuration" do
raketab = <<EOS
0 1 0 0 0 foo:bar
1,2,3,4,5,6 0 7,8 4 5 baz:blarg
EOS
      cron = append_tasks(@crontab, raketab)
      cron.should match(/0 1 0 0 0 [^\d]/)
      cron.should match(/1,2,3,4,5,6 0 7,8 4 5 [^\d]/)
    end

    it "should add a cd command" do
      raketab = "0 1 0 0 0 foo:bar"
      cron = append_tasks(@crontab, raketab)
      cron.should match(/0 1 0 0 0 cd /)
    end

    it "should add the rake command"
    it "should add the rails environment value"
    it "should ignore additional data at the end of the configuration"
  end

  describe "install" do
    it "should create a temporary file for crontab"
    it "should run crontab"
    it "should delete the temporary file"
  end

end