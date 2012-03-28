module Foxbat

  module SecureServer
    import javax.net.ssl.SSLContext
    import javax.net.ssl.KeyManagerFactory
    import javax.net.ssl.TrustManagerFactory
    import javax.net.ssl.SSLEngineResult
    import java.security.KeyStore
    import java.io.FileInputStream

    def setup_keystore(path)
      keystore = KeyStore.getInstance(KeyStore.getDefaultType)
      fis = FileInputStream.new(path)
      
      puts 'Enter passphrase for keystore:'
      password = java.lang.System.console.readPassword

      begin
        keystore.load(fis, password)
      rescue IOException
        puts 'Invalid passphrase.'
        fis.close
        return setup_keystore(path)
      end
      fis.close

      kmf = KeyManagerFactory.getInstance('SunX509')
      tmf = TrustManagerFactory.getInstance('SunX509')

      kmf.init(keystore, password)
      tmf.init(keystore)

      password = nil # Paranoid, per the JavaDoc

      puts 'Keystore successfully loaded.'
      
      [kmf, tmf]
    end

    def setup_ssl_context(keystore_path)
      @secure = true
      @ssl_context = SSLContext.getInstance('TLSv1')
      kmf, tmf = setup_keystore(keystore_path)
      @ssl_context.init(kmf.getKeyManagers, tmf.getTrustManagers, nil)
    end
    
    def create_ssl_engine
      engine = @ssl_context.createSSLEngine
      engine.setUseClientMode(false)
      engine.setNeedClientAuth(false)
      engine
    end
    
  end

end
