require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Thread#key?" do
  before :each do
    @th = Thread.new do
      Thread.current[:oliver] = "a"
    end
    @th.join
  end

  it "tests for existance of thread local variables using symbols or strings" do
    @th.key?(:oliver).should == true
    @th.key?("oliver").should == true
    @th.key?(:stanley).should == false
    @th.key?(:stanley.to_s).should == false
  end

  quarantine! do
    ruby_version_is ""..."1.9" do
      it "raises exceptions on the wrong type of keys" do
        lambda { Thread.current.key? nil }.should raise_error(TypeError)
        lambda { Thread.current.key? 5 }.should raise_error(ArgumentError)
      end
    end
  end

  ruby_version_is "1.9" do
    it "raises exceptions on the wrong type of keys" do
      lambda { Thread.current.key? nil }.should raise_error(TypeError)
      lambda { Thread.current.key? 5 }.should raise_error(TypeError)
    end

    it "is not shared across fibers" do
      fib = Fiber.new do
        Thread.current[:val1] = 1
        Fiber.yield
        Thread.current.key?(:val1).should be_true
        Thread.current.key?(:val2).should be_false
      end
      Thread.current.key?(:val1).should_not be_true
      fib.resume
      Thread.current[:val2] = 2
      fib.resume
      Thread.current.key?(:val1).should be_false
      Thread.current.key?(:val2).should be_true
    end
  end
end
