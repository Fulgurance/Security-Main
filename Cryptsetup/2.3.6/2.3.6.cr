class Target < ISM::Software

    def configure
        super

        configureSource([   "--prefix=/usr"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource([Ism.settings.makeOptions],buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        if option("Openrc")
            dmcryptData = <<-CODE
            # /etc/conf.d/dmcrypt
            # Global options:
            #----------------

            # How long to wait for each timeout (in seconds).
            dmcrypt_key_timeout=1

            # Max number of checks to perform (see dmcrypt_key_timeout).
            #dmcrypt_max_timeout=300

            # Number of password retries.
            dmcrypt_retries=5

            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/conf.d/dmcrypt",dmcryptData)

            makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/init.d")
            moveFile("#{workDirectoryPath(false)}2.4.3-dmcrypt.rc","#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/init.d/dmcrypt")
            runChmodCommand(["+x","dmcrypt"],"#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/init.d")
        end
    end

end
