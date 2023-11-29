class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super

    end

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--localstatedir=/var",
                            "--sysconfdir=/etc",
                            "--docdir=/usr/share/doc/gnupg-2.4.3"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

end
