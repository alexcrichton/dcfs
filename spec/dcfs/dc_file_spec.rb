require 'spec_helper'

describe DCFS::DCFile do
  before :each do
    @client   = mock(Object)
    @download = mock(Object, :size => 100.megabytes,
      :name => '/path/to/nowhere', :tth => 'tth')
    @file     = DCFS::DCFile.new 'nick', '/path/to/nowhere', @client, @download

    @client.stub(:timeout_response).and_yield
    @client.stub(:subscribe) { |blk| @subscribed_block = blk }
    @client.stub(:unsubscribe)
    @client.instance_variable_set('@cache_file', '/path/to/nowhere')
    File.stub(:open).with('/path/to/nowhere')
  end

  it "downloads the first chunk from the client" do
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      10.megabytes, 0)

    @file.read 10, 0
  end

  it "downloads the entire first chunk if it's bigger than 10 MB" do
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      11.megabytes, 0)

    @file.read 11.megabytes, 0
  end

  it "reads the first 10 megabytes and then serves up from there" do
    @client.should_receive(:download).once

    @file.read 10, 0

    @subscribed_block.call :download_progress, :nick => 'nick', :size => 1000,
        :file => '/path/to/nowhere'

    50.times{ |i|
      @file.read 10, 10 * i
    }

    @subscribed_block.call :download_progress, :nick => 'nick',
        :size => 10.megabytes, :file => '/path/to/nowhere'

    @file.read 9.megabytes, 0
  end

  it "reads the next 10 megabytes after reading the first 10" do
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      10.megabytes, 0).ordered
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      10.megabytes, 10.megabytes).ordered

    @file.read 10, 0

    @subscribed_block.call :download_progress, :nick => 'nick',
        :size => 10.megabytes, :file => '/path/to/nowhere'
    @subscribed_block.call :download_finished, :nick => 'nick'

    @file.read 10, 10.megabytes
  end

  it "doesn't read past the end of the file" do
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      1.megabyte, 99.megabytes).ordered

    @file.read 10, 99.megabytes
  end

  it "doesn't read all of the interim data when the gap is > 10 MB" do
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      10.megabytes, 0).ordered
    @client.should_receive(:download).with('nick', '/path/to/nowhere', 'tth',
      1.megabyte, 99.megabytes).ordered

    @file.read 10, 0

    @subscribed_block.call :download_progress, :nick => 'nick',
        :size => 10.megabytes, :file => '/path/to/nowhere'
    @subscribed_block.call :download_finished, :nick => 'nick'

    @file.read 10, 99.megabytes
  end
end
