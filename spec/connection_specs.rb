

require "aresmush"

module AresMUSH

  describe Connection do

    before do
      @connection = Connection.new(nil)
    end
      
    describe :ping do
      it "should send an empty string" do
        expect(@connection).to receive(:send_data).with("\e[0m")
        @connection.ping
      end
    end
    
    describe :send_formatted do
      it "should format the message before sending" do
        expect(MushFormatter).to receive(:format) { "TEST" }
        expect(@connection).to receive(:send_data).with("TEST")
        @connection.send_formatted("test")
      end
      
      it "should pass along ansi and screen reader settings" do
        settings = ClientDisplaySettings.new
        settings.ascii_mode = true
        settings.color_mode = "ANSI"
        settings.screen_reader = true
        settings.emoji_enabled = false
        
        expect(MushFormatter).to receive(:format) do |msg, display_settings|
          expect(display_settings.ascii_mode).to eq true
          expect(display_settings.color_mode).to eq "ANSI"
          expect(display_settings.screen_reader).to eq true
          expect(display_settings.emoji_enabled).to eq false
          expect(msg).to eq "test"
          "TEST" 
        end
        
        expect(@connection).to receive(:send_data).with("TEST")
        @connection.send_formatted("test", settings)
      end
    end    
    
    describe :receive_data do
      before do
        @client = double
        allow(@client).to receive(:id) { 1 }
        @connection.connect_client @client
        negotiator = double
        @connection.negotiator = negotiator
        allow(negotiator).to receive(:handle_input) do |data|
          data
        end
      end
      
      it "should send data to the client" do
        expect(@client).to receive(:handle_input).with("test\n")
        @connection.receive_data("test\n")        
      end
      
      it "should strip null control codes" do
        expect(@client).to receive(:handle_input).with("test\n")
        @connection.receive_data("test^@\0\n")
      end
      
      it "should handle multiple commands" do
        expect(@client).to receive(:handle_input).with("test1\n")
        expect(@client).to receive(:handle_input).with("test2\n")
        @connection.receive_data("test1\ntest2\n")
      end
      
      it "should handle multiple inputs separated with double line ends and ignore null commands" do
        expect(@client).to receive(:handle_input).with("echo 1\n")
        expect(@client).to receive(:handle_input).with("echo 2\n")
        @connection.receive_data("echo 1\n\necho 2\n\n")
      end
      
      it "should accumulate partial commands" do
        expect(@client).to receive(:handle_input).with("test\n")
        @connection.receive_data("te")
        @connection.receive_data("st\n")
      end
      
      it "should convert control code newline to newline" do
        expect(@client).to receive(:handle_input).with("test\nfoo\n")
        @connection.receive_data("test^Mfoo\n")    
      end
      
      it "should not send blank text" do
        expect(@client).to_not receive(:handle_input).with("   ")
        @connection.receive_data("   \n")    
      end
      
      it "should send only punctuation" do
        expect(@client).to receive(:handle_input).with(":...\n")
        @connection.receive_data(":...\n")
      end
    end
    
    describe :unbind do
      it "should notify the client that it disconnected" do
        client = double
        allow(client).to receive(:id) { 1 }
        @connection.connect_client client
        expect(client).to receive(:connection_closed)
        @connection.unbind
      end
    end
  end
end
