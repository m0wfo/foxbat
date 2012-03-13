import java.nio.charset.Charset

module EventMachine

  class Connection

    attr_accessor :channel

    def send_data(data)
      raise 'No socket channel to write to!' if @channel.nil?
      
      @charset ||= Charset.forName("UTF-8")
      buffer = @charset.encode(data)
      @channel.write(buffer)
    end
  end

end
