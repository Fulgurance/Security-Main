class Target < ISM::Software

    def configure
        super

        configureSource([   "--prefix=/usr"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)

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

            prepareOpenrcServiceInstallation("#{workDirectoryPath(false)}2.4.3-dmcrypt.rc","dmcrypt")
        end
    end

end
