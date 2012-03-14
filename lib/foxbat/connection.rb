module Foxbat

  class Connection

    attr_accessor :channel

    def send_data(data)
      raise 'No socket channel to write to!' if @channel.nil?

      arr = data.to_java_bytes
      buffer = java.nio.ByteBuffer.allocate(arr.length)
      buffer.put(arr)

      @channel.write(buffer)
    end

    def close_connection(after_writing=false)
      @channel.close
    end
  end

end
