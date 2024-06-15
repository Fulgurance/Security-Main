class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super

    end

    def configure
        super

        configureSource(arguments:  "--prefix=/usr          \
                                    --localstatedir=/var    \
                                    --sysconfdir=/etc       \
                                    --docdir=/usr/share/doc/gnupg-2.4.3",
                        path:       buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource( arguments:  "DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath} install",
                    path:       buildDirectoryPath)
    end

end
