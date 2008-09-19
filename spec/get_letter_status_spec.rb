require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Get Letter Status" do
  
  before :each do
    @doc = open(File.dirname(__FILE__) + '/../doc/sample.pdf')
    @client = PostalMethods::Client.new(PM_OPTS)
    @client.prepare!
    sleep(10)
  end
  
  it "should send a letter and get status" do
    ## use a static known good id that has gone thru in dev mode
    f = @client.get_letter_status(1023577)
    f.length.should == 2
    f.first.to_i.should == -1002
  end
  
  it "should try to get status of a letter i don't have access to" do
    lambda { @client.get_letter_status(1)}.should raise_error(PostalMethods::APIStatusCode3001Exception)
  end
  
  
  it "should send multiple letters and get their status" do
    letters = []
    1.upto(3) do
      @doc = open(File.dirname(__FILE__) + '/../doc/sample.pdf')
      @client = PostalMethods::Client.new(PM_OPTS)
      @client.prepare!      
      rv = @client.send_letter(@doc, "the long goodbye").sendLetterResult
      rv.to_i.should > 0
      letters << rv
      #sleep(10) # api needs some time
    end
    
    ret = @client.get_letter_status_multiple(letters)
    ret.should be_an_instance_of(Array)
    
    # the return is an array [results, status]
    recv_letters = ret.collect { |r| r.iD }
  
    recv_letters.should == letters
  end

  it "should attempt to request a multiple array of invalid letters" do
      ret = @client.get_letter_status_multiple(1,2,3)
      ret.should be_an_instance_of(Array)

      # the return is an array [results, status]
      recv_letters = ret.collect { |r| r.iD }

      recv_letters.should == letters
    end
    


  it "should request a range of letters and get their status" do
    letters = []
    1.upto(3) do
      @doc = open(File.dirname(__FILE__) + '/../doc/sample.pdf')
      @client = PostalMethods::Client.new(PM_OPTS)
      @client.prepare!      
      rv = @client.send_letter(@doc, "the long goodbye").sendLetterResult
      rv.to_i.should > 0
      letters << rv
      #sleep(10) # api needs some time
    end
    
    ret = @client.get_letter_status_range(letters.first, letters.last)
    ret.should be_an_instance_of(Array)
    
    # the return is an array [results, status]
    recv_letters = ret.collect { |r| r.iD }

    recv_letters.should == letters
  end

end
