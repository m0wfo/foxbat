module Foxbat

  class Security
    import javax.net.ssl.SSLContext
    import javax.net.ssl.KeyManagerFactory
    import javax.net.ssl.TrustManagerFactory
    import javax.net.ssl.SSLEngineResult
    import java.security.KeyStore
    import java.io.FileInputStream

    def self.setup_keystore(path)
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

      algorithm = KeyManagerFactory.getDefaultAlgorithm
      kmf = KeyManagerFactory.getInstance(algorithm)
      tmf = TrustManagerFactory.getInstance(algorithm)

      kmf.init(keystore, password)
      tmf.init(keystore)

      password = nil # Paranoid, per the JavaDoc

      puts 'Keystore successfully loaded.'
      
      [kmf, tmf]
    end

    def self.setup_ssl_context(keystore_path)
      context = SSLContext.getInstance('TLSv1')
      kmf, tmf = setup_keystore(keystore_path)
      context.init(kmf.getKeyManagers, tmf.getTrustManagers, nil)
      context
    end

    def self.setup_ssl_client_context
#      keystore = KeyStore.getInstance(KeyStore.getDefaultType)
#      context = SSLContext.getInstance('TLSv1')
#      tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm)
#      tmf.init(keystore)
#      context.init(nil, nil, nil)
      #      context
      SSLContext.getDefault
    end

    def self.create_ssl_engine(context, client=false)
      context.createSSLEngine
      engine.setUseClientMode(client)
      engine.setNeedClientAuth(false)
      engine
    end
    
  end

end
