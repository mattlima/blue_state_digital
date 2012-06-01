require 'spec_helper'
require 'blue_state_digital/connection'
require 'timecop'

describe BlueStateDigital::Connection do
  let(:api_host) { 'enoch.bluestatedigital.com:17260' }
  let(:api_id) { 'sfrazer' }
  let(:api_secret) { '7405d35963605dc36702c06314df85db7349613f' }
  
  before :each do
    BlueStateDigital::Connection.establish(api_host, api_id, api_secret)
  end
  
  describe "#perform_request" do
    it "should perform POST request" do
      timestamp = Time.now
      Timecop.freeze(timestamp) do
        api_call = '/somemethod'
        api_ts = timestamp.utc.to_i.to_s
        api_mac = BlueStateDigital::Connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '1', api_id: api_id, api_ts: api_ts })

        stub_url = "http://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=1"
        stub_request(:post, stub_url).with do |request|
          request.body.should == "a=b"
          request.headers['Accept'].should == 'text/xml'
          request.headers['Content-Type'].should == 'application/x-www-form-urlencoded'
          true
        end

        BlueStateDigital::Connection.perform_request(api_call, params = {}, method = "POST", body = "a=b")
      end
    end

    it "should perform GET request" do
      timestamp = Time.now
      Timecop.freeze(timestamp) do
        api_call = '/somemethod'
        api_ts = timestamp.utc.to_i.to_s
        api_mac = BlueStateDigital::Connection.compute_hmac("/page/api#{api_call}", api_ts, { api_ver: '1', api_id: api_id, api_ts: api_ts })

        stub_url = "http://#{api_host}/page/api/somemethod?api_id=#{api_id}&api_mac=#{api_mac}&api_ts=#{api_ts}&api_ver=1"
        stub_request(:get, stub_url)

        BlueStateDigital::Connection.perform_request(api_call, params = {})
      end
    end
  end
  
  describe "#compute_hmac" do
    it "should compute proper hmac hash" do
      params = { api_ver: '1', api_id: api_id, api_ts: '1272659462' }
      BlueStateDigital::Connection.compute_hmac('/page/api/circle/list_circles', '1272659462', params).should == '13e9de81bbdda506b6021579da86d3b6edea9755'
    end
  end
end